#!/bin/bash
# Kyverno must have registered its webhook configurations with the API server.
kubectl get validatingwebhookconfiguration kyverno-policy-validating-webhook-cfg >/dev/null 2>&1 || exit 1
kubectl get validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg >/dev/null 2>&1 || exit 1
