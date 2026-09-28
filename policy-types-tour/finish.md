# Well done!

<br>

You used the three modern CEL-based Kyverno policy types:

- **ValidatingPolicy** — enforced with `Deny`, then reported with `Audit`.
- **MutatingPolicy** — injected a default label.
- **GeneratingPolicy** — generated a ConfigMap for every new Namespace.

## Bonus: legacy vs modern

The legacy `ClusterPolicy` / `Policy` (API `kyverno.io/v1`) are deprecated — use
the CEL types instead:

| A legacy ClusterPolicy rule of type | Becomes |
|-------------------------------------|---------|
| `validate` | **ValidatingPolicy** |
| `mutate` | **MutatingPolicy** |
| `generate` | **GeneratingPolicy** |

Apply a legacy `ClusterPolicy` and watch Kyverno warn you it is deprecated:

```
cat <<EOF | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: legacy-demo
spec:
  validationFailureAction: Audit
  rules:
    - name: require-team
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "label 'team' is required"
        pattern:
          metadata:
            labels:
              team: "?*"
EOF
```{{exec}}

Look for the `Warning: ... deprecated` line in the output, then clean it up:

```
kubectl delete clusterpolicy legacy-demo
```{{exec}}

## Learn more

- ValidatingPolicy: https://kyverno.io/docs/policy-types/validating-policy/
- MutatingPolicy: https://kyverno.io/docs/policy-types/mutating-policy/
- GeneratingPolicy: https://kyverno.io/docs/policy-types/generating-policy/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

<br>

Thanks for taking the tour — you're ready to write CEL-based Kyverno policies!
