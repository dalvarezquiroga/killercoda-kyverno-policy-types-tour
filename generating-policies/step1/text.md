# 1 · Generate a ConfigMap & synchronize

> **Docs:** [GeneratingPolicy](https://kyverno.io/docs/policy-types/generating-policy/)

A **GeneratingPolicy** creates resources when a trigger happens. Here, every
new Namespace gets a default ConfigMap. The resource to create is a YAML
template with CEL placeholders `(( ... ))`.

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

List the policy you just created, and see all the CEL policy types (their
names, API group and scope):

```
kubectl get generatingpolicy
```{{exec}}

```
kubectl api-resources | grep policies.kyverno.io
```{{exec}}

Create a Namespace to trigger the policy:

```
kubectl create namespace demo-app
```{{exec}}

Generation is asynchronous (it happens a moment later). Wait a few seconds,
then look:

```
kubectl get configmap default-config -n demo-app
```{{exec}}

Now see **synchronize** in action. Delete the ConfigMap and watch Kyverno
create it again:

```
kubectl delete configmap default-config -n demo-app
```{{exec}}

```
kubectl get configmap default-config -n demo-app -w
```{{exec interrupt}}

<details><summary>Info: synchronize and the CEL template</summary>

<br>

`synchronize.enabled: true` keeps the generated resource in sync with the
policy: if you delete or edit it, Kyverno restores it. The
`(( variables.nsName ))` placeholder is replaced with the name of the Namespace
that triggered the policy.

</details>

Click **CHECK** when the ConfigMap exists in `demo-app`.
