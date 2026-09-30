#!/bin/bash
[ "$(kubectl get pod nginx-mutated -o jsonpath='{.metadata.labels.hello}' 2>/dev/null)" = "world" ] || exit 1
