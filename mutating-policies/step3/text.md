# 3 · Challenge — inject `runAsNonRoot`

Injecting secure defaults is one of the most useful jobs of a MutatingPolicy.

**Goal:** a `MutatingPolicy` that adds `spec.securityContext.runAsNonRoot: true`
to **every** new Pod.

A starter file is waiting at **`~/challenge.yaml`** — open it in the editor on
the left, complete the TODO, then apply it:

```
kubectl apply -f ~/challenge.yaml
```{{exec}}

Check the injected field with a server-side dry-run (no Pod is created):

```
kubectl run mp-check --image=nginx --dry-run=server -o jsonpath='{.spec.securityContext.runAsNonRoot}' ; echo
```{{exec}}

It must print `true`.

<details><summary>Tip</summary>

<br>

- Mirror the resource shape: `spec` → `securityContext` → `runAsNonRoot`.
- With `ApplyConfiguration` that is:
  `Object.spec{ securityContext: Object.spec.securityContext{ runAsNonRoot: true } }`.
- `runAsNonRoot` is a **boolean**, so use `true`, not `"true"`.

</details>

<details><summary>Solution</summary>

<br>

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: default-run-as-non-root
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            spec: Object.spec{
              securityContext: Object.spec.securityContext{
                runAsNonRoot: true
              }
            }
          }
EOF
```{{exec}}

</details>

Click **CHECK** when the dry-run prints `true`.
