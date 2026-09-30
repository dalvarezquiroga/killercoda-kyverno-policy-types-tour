#!/bin/bash
# Auto-solve for Step 3: a MutatingPolicy that injects runAsNonRoot=true.

kubectl apply -f - <<'EOF'
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
