# 4 · Challenge — block the `:latest` tag

Now write a policy yourself. The image tag `:latest` is a classic anti-pattern:
it makes deployments non-reproducible.

**Goal:** a `ValidatingPolicy` that **denies** any Pod whose container image ends
in `:latest`, and **allows** pinned tags.

Write and apply your policy, then test it with a server-side dry-run (this runs
admission checks **without** creating the Pods):

```
kubectl run t-latest --image=nginx:latest --labels=team=platform,app.kubernetes.io/name=demo --dry-run=server
```{{exec}}

```
kubectl run t-pinned --image=nginx:1.27 --labels=team=platform,app.kubernetes.io/name=demo --dry-run=server
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
- Prefer a scaffold? A starter file is at `~/challenge.yaml` — edit it
  (`vim ~/challenge.yaml`) and apply with `kubectl apply -f ~/challenge.yaml`.

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

Click **CHECK** when `:latest` is blocked and pinned tags are allowed.
