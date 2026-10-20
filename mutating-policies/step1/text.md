# 1 · Add a label with ApplyConfiguration

> **Docs:** [MutatingPolicy](https://kyverno.io/docs/policy-types/mutating-policy/)

A **MutatingPolicy** changes resources when they are created. You write the
patches in CEL with `patchType: ApplyConfiguration`, an `Object` that is
merged into the resource.

Create a policy that adds a simple `hello: world` label to every Pod:

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
resource. You only write the fields you want to add or change. This is easier
to read, and harder to get wrong, than raw JSON patches. The nested
`Object.metadata{...}` and `Object.metadata.labels{...}` follow the same
structure as the resource.

</details>

<br>

List the policy you just created, and see all the CEL policy types (their
names, API group and scope):

```
kubectl get mutatingpolicy
```{{exec}}

```
kubectl api-resources | grep policies.kyverno.io
```{{exec}}

<br>

Create a Pod and check the label that Kyverno added:

```
kubectl run nginx-mutated --image=nginx --labels=team=platform
```{{exec}}

```
kubectl get pod nginx-mutated -o jsonpath='{.metadata.labels}' ; echo
```{{exec}}

You should see `hello: world`, even though you never set it. Click **CHECK**.
