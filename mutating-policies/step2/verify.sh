#!/bin/bash
# Default tier applied when missing; existing tier preserved.
[ "$(kubectl get pod nginx-default-tier -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)" = "backend" ] || exit 1
[ "$(kubectl get pod nginx-frontend -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)" = "frontend" ] || exit 1
