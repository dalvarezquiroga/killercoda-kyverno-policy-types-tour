#!/bin/bash
[ "$(kubectl get pod nginx-mutated -o jsonpath='{.metadata.labels.foo}' 2>/dev/null)" = "bar" ] || exit 1
