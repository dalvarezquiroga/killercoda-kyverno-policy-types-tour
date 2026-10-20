# 4 · Challenge — exempt a namespace

Now write an exception yourself. The `sandbox` namespace is a playground where
developers try things out quickly, and the platform team agreed that Pods there
don't need a `team` label.

**Goal:** a `PolicyException` that exempts **every Pod in the `sandbox`
namespace** from `require-team-label` — and nothing outside it.

Write and apply your exception, then test it with server-side dry-runs:

```
kubectl run sandbox-test -n sandbox --image=nginx --dry-run=server
```{{exec}}

```
kubectl run default-test --image=nginx --dry-run=server
```{{exec}}

The first must be **allowed**, the second still **blocked**.

<details><summary>Tip</summary>

<br>

- Reuse the shape of `allow-legacy-app` from Step 2.
- Where must the exception **live** for Kyverno to read it? (Remember Step 3.)
- Match on the Pod's namespace instead of its name:
  `object.metadata.namespace == 'sandbox'`.
- Kyverno reloads the policy when an exception is created — if the first test
  is still blocked, wait a couple of seconds and retry.
- Prefer a scaffold? A starter file is at `~/challenge.yaml` — edit it
  (`vim ~/challenge.yaml`) and apply with `kubectl apply -f ~/challenge.yaml`.

</details>

<details><summary>Solution</summary>

<br>

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: allow-sandbox
  namespace: exceptions
spec:
  policyRefs:
    - name: require-team-label
      kind: ValidatingPolicy
  matchConditions:
    - name: only-sandbox
      expression: "object.metadata.namespace == 'sandbox'"
EOF
```{{exec}}

<br>

Reference: [Kyverno Policy Exceptions docs](https://kyverno.io/docs/guides/exceptions/).

</details>

Click **CHECK** when Pods in `sandbox` are allowed and Pods elsewhere are still
blocked.
