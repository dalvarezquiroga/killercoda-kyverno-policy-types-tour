# Validate resources

> **Docs:** [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy/)

A **ValidatingPolicy** decides whether a resource is allowed. The action is set
with `spec.validationActions`:

| Action | Effect |
|--------|--------|
| `Deny` | Blocks the request |
| `Audit` | Allows it, but records the violation in a PolicyReport |
| `Warn` | Allows it, but returns a warning |

<br>

## 1. Enforce with Deny

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

The rule requires a **team** label on every Pod. Thanks to the optional accessor
and `orValue([])`, the expression returns an empty list instead of erroring when
a Pod has no labels at all.

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

## 2. Report with Audit

Switch the same policy to `Audit`. Non-compliant Pods are no longer blocked,
but violations are recorded in a PolicyReport:

```
kubectl patch validatingpolicy require-team-label --type=json \
  -p='[{"op":"replace","path":"/spec/validationActions","value":["Audit"]}]'
```{{exec}}

```
kubectl run nginx-audit --image=nginx
```{{exec}}

Pods created with `kubectl run` land in the `default` namespace, and Kyverno
records the report right there. Inspect it:

```
kubectl get policyreport -n default
```{{exec}}

<details><summary>Tip: what to look for</summary>

<br>

The **nginx-audit** Pod is created (Audit does not block), but a PolicyReport in
the **default** namespace now has an entry with result `fail` for
`require-team-label`. PolicyReports live in the same namespace as the resource
they describe. Switch the policy back to `Deny` to enforce again.

</details>
