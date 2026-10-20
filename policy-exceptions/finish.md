# Well done!

Here's what you learned today — the CEL-based **PolicyException**:

- Pointed an exception at a policy with `policyRefs`, and scoped it to a single
  Pod with CEL `matchConditions`.
- Saw the exemption recorded as a `skip` in the **PolicyReport**.
- Learned that exceptions outside the allowed namespace are **silently
  ignored**, and how that becomes an approval gate with RBAC.
- Time-boxed and documented an exception with `expiresAt` and `properties`.
- And you wrote your own exception for a whole namespace.

## Tips & common pitfalls

- **Off by default:** enable them with `features.policyExceptions.enabled=true`
  and pick the namespace with `features.policyExceptions.namespace`. Prefer one
  dedicated namespace over `"*"`.
- **Wrong namespace, no error:** an exception outside the allowed namespace is
  accepted by the API server but ignored by Kyverno — check the namespace first
  when an exception "doesn't work".
- **Keep them narrow:** exempt one workload, not a whole cluster. Combine
  conditions (name **and** namespace) when you can.
- **Mind the name:** `polex` is the legacy `kyverno.io` kind. List CEL
  exceptions with `kubectl get policyexceptions.policies.kyverno.io -A`.
- **Exceptions expire, objects don't:** clean up expired exceptions, for
  example with a DeletingPolicy.

## Learn more

- Policy Exceptions: https://kyverno.io/docs/guides/exceptions/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Container flags (`enablePolicyException`, `exceptionNamespace`): https://kyverno.io/docs/installation/customization/

> These docs follow the current Kyverno release. This lab targets **v1.19** — if
> you land on a newer version, use the **Select version** menu on kyverno.io.

Next up: **High Availability** — run Kyverno so it survives a failure.
