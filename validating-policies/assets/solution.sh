#!/bin/bash
# Auto-solve for Step 4: a ValidatingPolicy that blocks the ':latest' tag.

kubectl apply -f - <<'EOF'
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
