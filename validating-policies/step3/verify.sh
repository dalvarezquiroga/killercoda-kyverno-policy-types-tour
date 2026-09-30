#!/bin/bash
[ "$(kubectl get validatingpolicy warn-missing-app-name -o jsonpath='{.spec.validationActions[0]}' 2>/dev/null)" = "Warn" ] || exit 1
