#!/bin/bash
# Unlabeled Pods must be allowed in sandbox and still blocked elsewhere.
# Server dry-run runs admission (incl. Kyverno) without creating Pods. Retry
# briefly: Kyverno reloads the policy right after the exception is created.
allowed=1
for i in $(seq 1 10); do
  if kubectl run pe-sandbox -n sandbox --image=nginx --dry-run=server >/dev/null 2>&1; then
    allowed=0; break
  fi
  sleep 2
done
[ "$allowed" -eq 0 ] || exit 1
kubectl run pe-default --image=nginx --dry-run=server >/dev/null 2>&1 && exit 1
exit 0
