# 4 · Challenge — block the `:latest` tag

Now write a policy yourself. Using the image tag `:latest` is a bad practice:
the image can change at any time, so you can't tell which version is running.

**Goal:** a `ValidatingPolicy` that **blocks** any Pod with a container image
that ends in `:latest`, and **allows** fixed version tags (like `nginx:1.27`).

Write and apply your policy. Then test it with a server-side dry-run (Kyverno
checks the request, but the Pods are **not** created):

```
kubectl run t-latest --image=nginx:latest --labels=team=platform,app.kubernetes.io/name=demo --dry-run=server
```{{exec}}

```
kubectl run t-pinned --image=nginx:1.27 --labels=team=platform,app.kubernetes.io/name=demo --dry-run=server
```{{exec}}

The first must be **blocked**, and the second **allowed**.

<details><summary>Tip</summary>

<br>

- Match `pods` in `matchConstraints.resourceRules`, like in the previous steps.
- A Pod can have several containers — check **all** of them:
  `object.spec.containers.all(c, ...)`.
- CEL strings have `endsWith`: `c.image.endsWith(':latest')`.
- The expression must be **true when the Pod is OK**, so negate it with `!`:
  `!c.image.endsWith(':latest')`.
- Want a starting point? There is a starter file at `~/challenge.yaml`. Edit it
  (`vim ~/challenge.yaml`) and apply it with `kubectl apply -f ~/challenge.yaml`.

</details>

<details><summary>Solution</summary>

<br>

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: block-latest-tag
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
    - message: "images must use a pinned tag, not ':latest'"
      expression: "object.spec.containers.all(c, !c.image.endsWith(':latest'))"
EOF
```{{exec}}

<br>

Reference: [Kyverno ValidatingPolicy docs](https://kyverno.io/docs/policy-types/validating-policy/).

</details>

Click **CHECK** when `:latest` is blocked and fixed version tags are allowed.
