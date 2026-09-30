#!/bin/bash
kubectl get validatingpolicy require-team-label >/dev/null 2>&1 || exit 1
[ "$(kubectl get pod nginx-team -o jsonpath='{.metadata.labels.team}' 2>/dev/null)" = "platform" ] || exit 1
