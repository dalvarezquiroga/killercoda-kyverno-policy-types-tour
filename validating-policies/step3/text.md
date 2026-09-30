# 3 · Dynamic messages & Warn

`Warn` admits the resource but returns a warning to whoever created it — great
for guiding users without blocking them. Combine it with `messageExpression` to
build a **dynamic** message.

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
  validations:
    - expression: "'app.kubernetes.io/name' in object.metadata.?labels.orValue([])"
      messageExpression: "'Pod ' + object.metadata.name + ' is missing the app.kubernetes.io/name label'"
EOF
```{{exec}}

Create a Pod without that label and watch the warning appear in the output:

```
kubectl run nginx-warn --image=nginx --labels=team=platform
```{{exec}}

<details><summary>Info: what is messageExpression?</summary>

<br>

`message` is a **fixed** text. `messageExpression` builds the text with CEL, so
it can include live data from the resource.

Here, `object.metadata.name` is the name of the Pod being checked, so each
warning names the exact Pod — for example *"Pod nginx-warn is missing ..."*.

Use `message` for a fixed string, and `messageExpression` when you want details
from the resource itself.

</details>

Click **CHECK** when the warning policy is applied.
