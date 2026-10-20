#!/bin/bash
# Auto-solve for Step 3: a DeletingPolicy that deletes ConfigMaps labeled
# expired=true in the demo namespace every minute.

kubectl apply -f - <<'EOF'
apiVersion: policies.kyverno.io/v1
kind: DeletingPolicy
metadata:
  name: cleanup-expired-configmaps
spec:
  schedule: "*/1 * * * *"
  matchConstraints:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: demo
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["configmaps"]
  conditions:
    - name: is-expired
      expression: "object.metadata.?labels.?expired.orValue('') == 'true'"
EOF

# The test ConfigMaps from the step text, so CHECK has something to verify.
kubectl create configmap keep-config -n demo --from-literal=mode=current 2>/dev/null || true
kubectl create configmap old-config -n demo --from-literal=mode=legacy 2>/dev/null || true
kubectl label configmap old-config -n demo expired=true --overwrite 2>/dev/null || true
