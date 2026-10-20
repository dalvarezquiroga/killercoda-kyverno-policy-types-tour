# 1 · Scheduled cleanup of Pods

> **Docs:** [DeletingPolicy](https://kyverno.io/docs/policy-types/deleting-policy/)

A **DeletingPolicy** has three key parts:

| Field | Purpose |
|-------|---------|
| `schedule` | When to run, in cron format (minimum: every minute) |
| `matchConstraints` | Which kinds (and namespaces) to look at |
| `conditions` | CEL expressions — a resource is deleted only if **all** are `true` |

## The RBAC gotcha

Deletions are done by Kyverno's **cleanup controller**. By default it is **not**
allowed to delete your Pods, Jobs or ConfigMaps — and without permission the
policy simply does nothing, silently. You grant access by aggregating a
ClusterRole with this label:

```
rbac.kyverno.io/aggregate-to-cleanup-controller: "true"
```

That RBAC was already applied for you during setup. Take a look, then ask the
API server whether the cleanup controller may now delete Pods:

```
kubectl get clusterrole kyverno:cleanup-extra -o yaml
```{{exec}}

```
kubectl auth can-i delete pods -n demo \
  --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```{{exec}}

## Delete temporary Pods every minute

Create a policy that, **every minute**, deletes Pods in the `demo` namespace
labeled `cleanup=true`:

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

<details><summary>Info: scope destructive policies narrowly</summary>

<br>

A DeletingPolicy **really deletes things**, so scope it as tightly as you can:

- `namespaceSelector` limits it to the `demo` namespace (every namespace carries
  the built-in label `kubernetes.io/metadata.name`).
- The CEL condition then picks only Pods labeled `cleanup=true`.
  `.?labels.?cleanup.orValue('')` reads the label safely, even when a Pod has
  no labels at all.

</details>

<br>

List the policy (short name `dpol`):

```
kubectl get deletingpolicy
```{{exec}}

<br>

Create two Pods — one temporary, one that must survive:

```
kubectl run temp-pod -n demo --image=nginx --labels=cleanup=true
```{{exec}}

```
kubectl run keep-pod -n demo --image=nginx
```{{exec}}

Now wait for the next run of the schedule (up to a minute). This command returns
as soon as `temp-pod` is gone:

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

Kyverno can emit a `PolicyApplied` event for every deleted resource, but
**success events are off by default** to keep the cluster quiet. To enable them
you would install Kyverno with `config.generateSuccessEvents=true` and remove
`PolicyApplied` from `features.omitEvents.eventTypes`. Then:

```
kubectl get events -A --field-selector reason=PolicyApplied
```

</details>

<details><summary>Tip: how to debug a policy that deletes nothing</summary>

<br>

- Missing RBAC is the usual suspect — the cleanup controller skips kinds it is
  not allowed to list or delete. Check its logs:
  ```
  kubectl -n kyverno logs deploy/kyverno-cleanup-controller | grep -iE "forbidden|access|delet"
  ```
- Remember a resource is deleted only when **every** condition is `true`.
- Kyverno never touches `kube-system` and other filtered namespaces — use your
  own namespace.

</details>

Click **CHECK** once `temp-pod` is gone and `keep-pod` is still running.
