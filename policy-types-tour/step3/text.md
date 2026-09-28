# Generate resources

> **Docs:** [GeneratingPolicy](https://kyverno.io/docs/policy-types/generating-policy/)

A **GeneratingPolicy** creates resources in response to a trigger. Here, every
new Namespace gets a default ConfigMap. The downstream resource is authored as a
YAML template with CEL placeholders `(( ... ))`.

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: generate-default-configmap
spec:
  evaluation:
    synchronize:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["namespaces"]
  variables:
    - name: nsName
      expression: "object.metadata.name"
  generate:
    - template:
        interpolate: cel
        value: |
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: default-config
            namespace: (( variables.nsName ))
          data:
            managed-by: kyverno
EOF
```{{exec}}

<details><summary>Info: synchronize and the CEL template</summary>

<br>

`synchronize.enabled: true` keeps the generated ConfigMap in sync — if you
delete it, Kyverno recreates it. The `(( variables.nsName ))` placeholder is
replaced with the name of the Namespace that triggered the policy.

</details>

<br>

Create a new Namespace to trigger the policy:

```
kubectl create namespace demo-app
```{{exec}}

Kyverno generates the ConfigMap for you (generation is asynchronous, give it a
few seconds):

```
kubectl get configmap default-config -n demo-app -o yaml
```{{exec}}
