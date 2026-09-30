# 4 · Challenge — block the `:latest` tag

Time to write a policy yourself. Using the image tag `:latest` is a classic
anti-pattern: it makes deployments non-reproducible.

**Goal:** a `ValidatingPolicy` that **denies** any Pod whose container image ends
in `:latest`, and **allows** pinned tags.

A starter file is waiting for you at **`~/challenge.yaml`** — open it in the
editor on the left, complete the TODOs, then apply it:

```
kubectl apply -f ~/challenge.yaml
```{{exec}}

Test your policy (a server-side dry-run triggers admission without creating
Pods):

```
kubectl run t-latest --image=nginx:latest --labels=team=platform --dry-run=server
```{{exec}}

```
kubectl run t-pinned --image=nginx:1.27 --labels=team=platform --dry-run=server
```{{exec}}

The first must be **blocked**, the second **allowed**.

<details><summary>Tip</summary>

<br>

- Match `pods` in `matchConstraints.resourceRules`, as in the previous steps.
- A Pod can have several containers — check them **all**:
  `object.spec.containers.all(c, ...)`.
- CEL strings support `endsWith`: `c.image.endsWith(':latest')`.
- The expression must be **true when the Pod is OK**, so negate it:
  `!c.image.endsWith(':latest')`.

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

</details>

Click **CHECK** when `:latest` is blocked and pinned tags are allowed.
