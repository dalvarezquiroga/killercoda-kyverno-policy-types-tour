# 1 · A policy that blocks

> **Docs:** [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy/)

To make an exception, you first need a rule. Create a **ValidatingPolicy** that
requires every Pod to carry a `team` label, and **denies** the ones that don't:

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

```
kubectl get validatingpolicy
```{{exec}}

<br>

Now meet `legacy-app` — an old workload nobody has relabeled yet. Try to run it:

```
kubectl run legacy-app --image=nginx
```{{exec}}

It is **blocked** with `label 'team' is required`. A compliant Pod is still
fine:

```
kubectl run web --image=nginx --labels=team=platform
```{{exec}}

<details><summary>Info: why not just weaken the policy?</summary>

<br>

You could add `legacy-app` to the policy itself, but then the policy keeps
growing with special cases and nobody can tell **why** each one is there.
A PolicyException keeps the policy clean and makes every exemption a separate,
reviewable object — with its own owner, reason and expiry.

</details>

Click **CHECK** once `legacy-app` is blocked and `web` is running.
