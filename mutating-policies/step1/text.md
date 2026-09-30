# 1 · Add a label with ApplyConfiguration

> **Docs:** [MutatingPolicy](https://kyverno.io/docs/policy-types/mutating-policy/)

A **MutatingPolicy** changes resources as they are created. Patches are written
as CEL using `patchType: ApplyConfiguration`, a merge-style `Object`.

Create a policy that adds a friendly `hello: world` label to every Pod:

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-default-label
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
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                hello: "world"
              }
            }
          }
EOF
```{{exec}}

<details><summary>Info: ApplyConfiguration patches</summary>

<br>

`ApplyConfiguration` builds a partial `Object` that is **merged** into the
resource. You only describe the fields you want to add or change — more readable
and less error-prone than raw JSON patches. The nested `Object.metadata{...}`
and `Object.metadata.labels{...}` mirror the shape of the resource.

</details>

<br>

List the policy you just created, and browse the whole family of CEL policy
types (their names, API group and scope):

```
kubectl get mutatingpolicy
```{{exec}}

```
kubectl api-resources | grep policies.kyverno.io
```{{exec}}

<br>

Create a Pod and check the label that Kyverno injected:

```
kubectl run nginx-mutated --image=nginx --labels=team=platform
```{{exec}}

```
kubectl get pod nginx-mutated -o jsonpath='{.metadata.labels}' ; echo
```{{exec}}

You should see `hello: world` even though you never set it. Click **CHECK**.
