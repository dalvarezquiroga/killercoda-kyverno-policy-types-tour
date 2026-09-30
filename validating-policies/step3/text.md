# 3 · Dynamic messages & Warn

`Warn` admits the resource but returns a warning to whoever created it — great
for guiding users without blocking them. Combine it with `variables` and
`messageExpression` to build a **dynamic** message.

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: warn-missing-app-name
spec:
  validationActions:
    - Warn
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  variables:
    - name: podName
      expression: "object.metadata.name"
  validations:
    - expression: "'app.kubernetes.io/name' in object.metadata.?labels.orValue([])"
      messageExpression: "'Pod ' + variables.podName + ' is missing the app.kubernetes.io/name label'"
EOF
```{{exec}}

Create a Pod without that label and watch the warning appear in the output:

```
kubectl run nginx-warn --image=nginx --labels=team=platform
```{{exec}}

<details><summary>Info: variables vs messageExpression</summary>

<br>

`variables` are named CEL expressions evaluated once and reused as
`variables.<name>` — handy to keep expressions readable. `messageExpression` is
a CEL string returning the failure message, so it can include live data from the
resource (here, the Pod name). Use `message` for a static string,
`messageExpression` for a dynamic one.

</details>

Click **CHECK** when the warning policy is applied.
