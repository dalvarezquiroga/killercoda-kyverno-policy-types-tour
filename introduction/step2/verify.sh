#!/bin/bash
# The CEL policy CRDs must be registered and the webhook certificate created.
kubectl wait --for=condition=established crd/validatingpolicies.policies.kyverno.io --timeout=10s >/dev/null 2>&1 || exit 1
kubectl get secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno >/dev/null 2>&1 || exit 1
