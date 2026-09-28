# Mutate resources

A **MutatingPolicy** changes resources as they are created. Patches are written
as CEL using `patchType: ApplyConfiguration`, a merge-style `Object`.

Create a policy that adds a default `foo: bar` label to every Pod:

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
                foo: "bar"
              }
            }
          }
EOF
```{{exec}}

<details><summary>Info: ApplyConfiguration patches</summary>

<br>

`ApplyConfiguration` builds a partial `Object` that is merged into the resource.
It is more readable and less error-prone than raw JSON patches — you only
describe the fields you want to add or change.

</details>

<br>

Create a Pod and check the label that Kyverno injected:

```
kubectl run nginx-mutated --image=nginx --labels=team=platform
```{{exec}}

```
kubectl get pod nginx-mutated -o jsonpath='{.metadata.labels}' ; echo
```{{exec}}

You should see `foo: bar` even though you never set it.
