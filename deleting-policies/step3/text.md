# 3 · Challenge — expire ConfigMaps

Now write a policy yourself. Teams mark old configuration with the label
`expired=true` and expect it to disappear on its own.

**Goal:** a `DeletingPolicy` that, **every minute**, deletes ConfigMaps in the
`demo` namespace labeled `expired=true` — and leaves every other ConfigMap
alone.

Write and apply your policy. Then create two ConfigMaps to test it — one
expired, one that must survive:

```
kubectl create configmap old-config -n demo --from-literal=mode=legacy
kubectl label configmap old-config -n demo expired=true
```{{exec}}

```
kubectl create configmap keep-config -n demo --from-literal=mode=current
```{{exec}}

Wait for the next run of the schedule (up to a minute):

```
kubectl wait --for=delete configmap/old-config -n demo --timeout=150s
```{{exec}}

```
kubectl get configmaps -n demo
```{{exec}}

`old-config` must be **gone**, `keep-config` must **still be there**.

<details><summary>Tip</summary>

<br>

- Start from the Pod policy in Step 1 — it has the same shape.
- ConfigMaps live in the core API group: `apiGroups: [""]`, `apiVersions: ["v1"]`,
  `resources: ["configmaps"]`.
- Every minute in cron is `"*/1 * * * *"`.
- Read the label safely: `object.metadata.?labels.?expired.orValue('') == 'true'`.
- The RBAC for `configmaps` was already granted during setup.
- Prefer a scaffold? A starter file is at `~/challenge.yaml` — edit it
  (`vim ~/challenge.yaml`) and apply with `kubectl apply -f ~/challenge.yaml`.
- Kyverno publishes ready-made cleanup policies in the
  [policy catalog](https://kyverno.io/policies/) — try it yourself first!

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

Click **CHECK** once `old-config` is gone and `keep-config` is still there.
