# Well done!

<br>

You used the three modern CEL-based Kyverno policy types:

- **ValidatingPolicy** — enforced with `Deny`, then reported with `Audit`.
- **MutatingPolicy** — injected a default label.
- **GeneratingPolicy** — generated a ConfigMap for every new Namespace.

## Bonus: detect legacy policies

Legacy `ClusterPolicy` / `Policy` objects are deprecated. List any that still
exist in a cluster:

```
kubectl get clusterpolicies.kyverno.io -A 2>/dev/null || echo "no legacy ClusterPolicies found"
```{{exec}}

## Learn more

- ValidatingPolicy: https://kyverno.io/docs/policy-types/validating-policy/
- MutatingPolicy: https://kyverno.io/docs/policy-types/mutating-policy/
- GeneratingPolicy: https://kyverno.io/docs/policy-types/generating-policy/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

<br>

Thanks for taking the tour! Explore the other scenarios in this course to keep
learning Kyverno.
