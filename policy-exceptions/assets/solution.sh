#!/bin/bash
# Auto-solve for Step 4: a PolicyException that exempts every Pod in the
# sandbox namespace from require-team-label.

kubectl apply -f - <<'EOF'
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: allow-sandbox
  namespace: exceptions
spec:
  policyRefs:
    - name: require-team-label
      kind: ValidatingPolicy
  matchConditions:
    - name: only-sandbox
      expression: "object.metadata.namespace == 'sandbox'"
EOF
