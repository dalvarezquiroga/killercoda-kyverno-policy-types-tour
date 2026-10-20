# 4 · Challenge — skip a whole namespace

Now write an exception yourself. Developers use the `sandbox` namespace as a
test area to try things quickly. The platform team agreed that Pods there
don't need a `team` label.

**Goal:** a `PolicyException` that lets **every Pod in the `sandbox`
namespace** skip `require-team-label` — and no Pod outside it.

Write and apply your exception. Then test it with server-side dry-runs:

```
kubectl run sandbox-test -n sandbox --image=nginx --dry-run=server
```{{exec}}

```
kubectl run default-test --image=nginx --dry-run=server
```{{exec}}

The first must be **allowed**, and the second must still be **blocked**.

<details><summary>Tip</summary>

<br>

- Use the same structure as `allow-legacy-app` from Step 2.
- In which namespace must the exception be for Kyverno to read it? (Remember
  Step 3.)
- Match the Pod's namespace instead of its name:
  `object.metadata.namespace == 'sandbox'`.
- Kyverno reloads the policy when an exception is created. If the first test
  is still blocked, wait a few seconds and try again.
- Want a starting point? There is a starter file at `~/challenge.yaml`. Edit it
  (`vim ~/challenge.yaml`) and apply it with `kubectl apply -f ~/challenge.yaml`.

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

Click **CHECK** when Pods in `sandbox` are allowed and Pods in other
namespaces are still blocked.
