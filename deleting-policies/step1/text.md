# 1 · Scheduled cleanup of Pods

> **Docs:** [DeletingPolicy](https://kyverno.io/docs/policy-types/deleting-policy/)

A **DeletingPolicy** has three main parts:

| Field | Purpose |
|-------|---------|
| `schedule` | When to run, in cron format (minimum: every minute) |
| `matchConstraints` | Which kinds (and namespaces) to look at |
| `conditions` | CEL expressions — a resource is deleted only if **all** are `true` |

## The RBAC problem

Kyverno's **cleanup controller** does the deleting. By default it is **not**
allowed to delete your Pods, Jobs or ConfigMaps. Without that permission, the
policy does nothing, and you see no error. To give it access, create a
ClusterRole with this label (an *aggregated* ClusterRole: Kubernetes adds its
rules to the cleanup controller's role):

```
rbac.kyverno.io/aggregate-to-cleanup-controller: "true"
```

The setup already created this ClusterRole for you. Look at it, then ask the
API server if the cleanup controller can now delete Pods:

```
kubectl get clusterrole kyverno:cleanup-extra -o yaml
```{{exec}}

```
kubectl auth can-i delete pods -n demo \
  --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```{{exec}}

## Delete temporary Pods every minute

Create a policy that runs **every minute** and deletes the Pods in the `demo`
namespace that have the label `cleanup=true`:

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: DeletingPolicy
metadata:
  name: cleanup-temp-pods
spec:
  schedule: "*/1 * * * *"
  matchConstraints:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: demo
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
  conditions:
    - name: is-temporary
      expression: "object.metadata.?labels.?cleanup.orValue('') == 'true'"
EOF
```{{exec}}

<details><summary>Info: keep a deleting policy small</summary>

<br>

A DeletingPolicy **really deletes things**, so limit it as much as you can:

- `namespaceSelector` limits it to the `demo` namespace. Every namespace has
  the built-in label `kubernetes.io/metadata.name`.
- The CEL condition then selects only Pods with the label `cleanup=true`.
  `.?labels.?cleanup.orValue('')` reads the label safely, even when a Pod has
  no labels at all.

</details>

<br>

List the policy (short name `dpol`):

```
kubectl get deletingpolicy
```{{exec}}

<br>

Create two Pods — one temporary, and one that must stay:

```
kubectl run temp-pod -n demo --image=nginx --labels=cleanup=true
```{{exec}}

```
kubectl run keep-pod -n demo --image=nginx
```{{exec}}

Now wait for the next scheduled run (up to one minute). This command finishes
as soon as `temp-pod` is deleted:

```
kubectl wait --for=delete pod/temp-pod -n demo --timeout=150s
```{{exec}}

```
kubectl get pods -n demo
```{{exec}}

Only `keep-pod` is left. Check when the policy last ran:

```
kubectl get deletingpolicy cleanup-temp-pods \
  -o jsonpath='{.status.lastExecutionTime}' ; echo
```{{exec}}

<details><summary>Info: why there is no "deleted" event</summary>

<br>

Kyverno can create a `PolicyApplied` event for every deleted resource, but
**success events are off by default**, so the cluster does not fill up with
events. To turn them on, you would install Kyverno with
`config.generateSuccessEvents=true` and remove `PolicyApplied` from
`features.omitEvents.eventTypes`. Then:

```
kubectl get events -A --field-selector reason=PolicyApplied
```

</details>

<details><summary>Tip: what to check when a policy deletes nothing</summary>

<br>

- Missing RBAC is the most common cause. The cleanup controller skips any kind
  it is not allowed to list or delete. Check its logs:
  ```
  kubectl -n kyverno logs deploy/kyverno-cleanup-controller | grep -iE "forbidden|access|delet"
  ```
- Remember: a resource is deleted only when **every** condition is `true`.
- Kyverno never deletes anything in `kube-system` or in other excluded
  namespaces. Use your own namespace.

</details>

Click **CHECK** when `temp-pod` is deleted and `keep-pod` is still running.
