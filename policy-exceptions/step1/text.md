# 1 · A policy that blocks

> **Docs:** [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy/)

Before you make an exception, you need a rule. Create a **ValidatingPolicy**
that requires every Pod to have a `team` label, and **blocks** the Pods that
don't:

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

Now meet `legacy-app` — an old app that nobody has given the label yet. Try
to run it:

```
kubectl run legacy-app --image=nginx
```{{exec}}

It is **blocked** with `label 'team' is required`. A Pod with the label still
works:

```
kubectl run web --image=nginx --labels=team=platform
```{{exec}}

<details><summary>Info: why not just change the policy?</summary>

<br>

You could add `legacy-app` to the policy itself. But then the policy gets
longer with every special case, and nobody remembers **why** each one is
there. A PolicyException keeps the policy clean. Each exception is a separate
object that people can review, with its own owner, reason and end date.

</details>

Click **CHECK** when `legacy-app` is blocked and `web` is running.
