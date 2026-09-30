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

<details><summary>Info: how the CEL expression works</summary>

<br>

`object.metadata.?labels` is an **optional accessor**: it returns the labels map
if present, or an *optional none* when the Pod has no labels. `.orValue([])`
turns that into an empty list, so `'team' in ...` never errors — it simply
returns `false`. This is the safe pattern for reading fields that may be missing.

</details>

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
