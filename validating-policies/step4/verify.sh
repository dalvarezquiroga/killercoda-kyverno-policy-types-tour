#!/bin/bash
# A ValidatingPolicy must block ':latest' and allow pinned tags.
# Server dry-run runs admission (incl. Kyverno) without creating Pods.
kubectl run vp-latest --image=nginx:latest --labels=team=platform --dry-run=server >/dev/null 2>&1 && exit 1
kubectl run vp-pinned --image=nginx:1.27 --labels=team=platform --dry-run=server >/dev/null 2>&1 || exit 1
exit 0
