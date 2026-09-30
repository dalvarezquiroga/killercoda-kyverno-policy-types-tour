# Well done!

Here's what you learned today — the CEL-based **ValidatingPolicy**:

- **Deny** to block, **Audit** to report, **Warn** to nudge.
- `matchConstraints.resourceRules` to scope what a policy sees.
- Safe CEL with optional accessors (`object.metadata.?labels.orValue([])`).
- Dynamic feedback with `variables` + `messageExpression`.
- **PolicyReports** to review Audit violations.
- And you wrote your own policy to block the `:latest` tag.

## Tips & common pitfalls

- **Null fields:** a Pod may have no `labels` at all. Use the optional accessor
  `object.metadata.?labels.orValue([])` so your expression never errors.
- **Roll out safely:** start a new rule in `Audit`, review the PolicyReports,
  then switch to `Deny`.
- **Reports live with the resource:** a Pod's PolicyReport is in the Pod's
  namespace, not in `kyverno`.
- **Expressions are boolean:** the resource is allowed only when every
  `validations[].expression` evaluates to `true`.

## Learn more

- ValidatingPolicy: https://kyverno.io/docs/policy-types/validating-policy/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

> These docs follow the current Kyverno release. This lab targets **v1.19** — if
> you land on a newer version, use the **Select version** menu on kyverno.io.

Next up: **MutatingPolicy** — change resources on the fly.
