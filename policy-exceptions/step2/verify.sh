#!/bin/bash
# The exception must live in the allowed namespace and let legacy-app in.
kubectl get policyexceptions.policies.kyverno.io allow-legacy-app -n exceptions >/dev/null 2>&1 || exit 1
kubectl get pod legacy-app >/dev/null 2>&1 || exit 1
