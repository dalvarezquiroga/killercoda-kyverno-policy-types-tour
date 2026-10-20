# Well done!

Here's what you learned today — the CEL-based **PolicyException**:

- Linked an exception to a policy with `policyRefs`, and limited it to a single
  Pod with CEL `matchConditions`.
- Saw the skip recorded as `skip` in the **PolicyReport**.
- Learned that Kyverno **ignores** exceptions outside the allowed namespace,
  without telling you — and how RBAC turns that namespace into an approval
  step.
- Added an end date and a reason to an exception with `expiresAt` and
  `properties`.
- And you wrote your own exception for a whole namespace.

## Tips & common mistakes

- **Off by default:** turn them on with `features.policyExceptions.enabled=true`
  and choose the namespace with `features.policyExceptions.namespace`. Use one
  dedicated namespace rather than `"*"` (all namespaces).
- **Wrong namespace, no error:** the API server accepts an exception outside
  the allowed namespace, but Kyverno ignores it. When an exception "doesn't
  work", check its namespace first.
- **Keep them small:** let one app skip the policy, not the whole cluster.
  Combine conditions (name **and** namespace) when you can.
- **Careful with the name:** `polex` is the old `kyverno.io` kind. List CEL
  exceptions with `kubectl get policyexceptions.policies.kyverno.io -A`.
- **Exceptions expire, the objects stay:** delete expired exceptions, for
  example with a DeletingPolicy.

## Learn more

- Policy Exceptions: https://kyverno.io/docs/guides/exceptions/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Container flags (`enablePolicyException`, `exceptionNamespace`): https://kyverno.io/docs/installation/customization/

> These docs follow the current Kyverno release. This lab uses **v1.19** — if
> you are on a newer version, use the **Select version** menu on kyverno.io.

Next up: **High Availability** — run Kyverno so it keeps working when something
fails.
