# 1 · Enforce with Deny

> **Docs:** [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy/)

A **ValidatingPolicy** decides whether a resource is admitted. The action lives
in `spec.validationActions`:

| Action | Effect |
|--------|--------|
| `Deny`  | Blocks the request |
| `Audit` | Allows it, records the violation in a PolicyReport |
| `Warn`  | Allows it, returns a warning |

<br>

Create a policy that requires every Pod to carry a `team` label:

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-team-label
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  validations:
    - message: "label 'team' is required"
      expression: "'team' in object.metadata.?labels.orValue([])"
EOF
```{{exec}}

<details><summary>Info: reading a label safely</summary>

<br>

A Pod might have **no labels at all**. If you read them directly, the expression
can error out.

`object.metadata.?labels.orValue([])` avoids that:

- `.?labels` reads the labels **only if they exist**.
- `.orValue([])` means "if there are none, use an empty list instead".

So `'team' in ...` simply returns `false` for a Pod with no labels, instead of
failing. Use this pattern whenever a field might be missing.

</details>

<br>

List the policy you just created, and browse the whole family of CEL policy
types (their names, API group and scope):

```
kubectl get validatingpolicy
```{{exec}}

```
kubectl api-resources | grep policies.kyverno.io
```{{exec}}

<br>

Try to create a Pod **without** the label — it is blocked:

```
kubectl run nginx-bad --image=nginx
```{{exec}}

Now create a compliant Pod. It is allowed:

```
kubectl run nginx-team --image=nginx --labels=team=platform
```{{exec}}

Click **CHECK** when the compliant Pod is created.
