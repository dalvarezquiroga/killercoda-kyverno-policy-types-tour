# 3 · Challenge — expire ConfigMaps

Now write a policy yourself. Teams add the label `expired=true` to old
configuration, and they want it to be deleted automatically.

**Goal:** a `DeletingPolicy` that runs **every minute** and deletes the
ConfigMaps in the `demo` namespace that have the label `expired=true`. All
other ConfigMaps must stay.

Write and apply your policy. Then create two ConfigMaps to test it — one
expired, and one that must stay:

```
kubectl create configmap old-config -n demo --from-literal=mode=legacy
kubectl label configmap old-config -n demo expired=true
```{{exec}}

```
kubectl create configmap keep-config -n demo --from-literal=mode=current
```{{exec}}

Wait for the next scheduled run (up to one minute):

```
kubectl wait --for=delete configmap/old-config -n demo --timeout=150s
```{{exec}}

```
kubectl get configmaps -n demo
```{{exec}}

`old-config` must be **deleted**, and `keep-config` must **still be there**.

<details><summary>Tip</summary>

<br>

- Start from the Pod policy in Step 1 — it has the same structure.
- ConfigMaps are in the core API group: `apiGroups: [""]`, `apiVersions: ["v1"]`,
  `resources: ["configmaps"]`.
- "Every minute" in cron is `"*/1 * * * *"`.
- Read the label safely: `object.metadata.?labels.?expired.orValue('') == 'true'`.
- The setup already gave the cleanup controller RBAC for `configmaps`.
- Want a starting point? There is a starter file at `~/challenge.yaml`. Edit it
  (`vim ~/challenge.yaml`) and apply it with `kubectl apply -f ~/challenge.yaml`.
- Kyverno publishes ready-made cleanup policies in the
  [policy catalog](https://kyverno.io/policies/) — but try it yourself first!

</details>

<details><summary>Solution</summary>

<br>

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: DeletingPolicy
metadata:
  name: cleanup-expired-configmaps
spec:
  schedule: "*/1 * * * *"
  matchConstraints:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: demo
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["configmaps"]
  conditions:
    - name: is-expired
      expression: "object.metadata.?labels.?expired.orValue('') == 'true'"
EOF
```{{exec}}

<br>

Reference: [Kyverno DeletingPolicy docs](https://kyverno.io/docs/policy-types/deleting-policy/).

</details>

Click **CHECK** when `old-config` is deleted and `keep-config` is still there.
