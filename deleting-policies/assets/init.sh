#!/bin/bash
# Real scenario setup. Uploaded to /ks and run hidden by init/background.sh.
# Installs a pinned Kyverno (chart 3.9.1 = v1.19.1) for the stable CEL policy
# CRDs (policies.kyverno.io/v1) and grants the RBAC the deleting steps need.

helm repo add kyverno https://kyverno.github.io/kyverno/ || true
helm repo update

# --wait blocks until every Kyverno component is Available. Replicas are pinned
# to 1 because this runs on a single-node cluster.
helm install kyverno kyverno/kyverno \
  -n kyverno --create-namespace \
  --version 3.9.1 \
  --wait --timeout 6m \
  --set admissionController.replicas=1 \
  --set backgroundController.replicas=1 \
  --set cleanupController.replicas=1 \
  --set reportsController.replicas=1

# The cleanup controller runs DeletingPolicies but cannot delete Pods, Jobs or
# ConfigMaps by default. Aggregate delete access for those kinds onto its
# ClusterRole.
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno:cleanup-extra
  labels:
    rbac.kyverno.io/aggregate-to-cleanup-controller: "true"
rules:
  - apiGroups: [""]
    resources: ["pods", "configmaps"]
    verbs: ["get", "list", "watch", "delete"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["get", "list", "watch", "delete"]
EOF

# A dedicated namespace keeps every deletion in this lab away from system
# workloads.
kubectl create namespace demo

# Make sure the DeletingPolicy CRD is established before Step 1.
kubectl wait --for=condition=established --timeout=2m \
  crd/deletingpolicies.policies.kyverno.io

# Record the installed Kyverno version for the welcome message.
kubectl -n kyverno get deploy kyverno-admission-controller \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null \
  | sed 's/.*://' > /ks/kyverno-version

# Signal the foreground spinner that setup is complete.
touch /ks/.initfinished
