# Well done!

Here's what you learned today — the CEL-based **ValidatingPolicy**:

- **Deny** to block, **Audit** to report, **Warn** to guide.
- `matchConstraints.resourceRules` to choose what a policy checks.
- Safe CEL with optional fields (`object.metadata.?labels.orValue([])`).
- Dynamic messages with `messageExpression`.
- **PolicyReports** to review Audit violations.
- And you wrote your own policy to block the `:latest` tag.

## Tips & common mistakes

- **Missing fields:** a Pod may have no `labels` at all. Use
  `object.metadata.?labels.orValue([])` so your expression never fails.
- **Start safely:** start a new rule in `Audit`, review the PolicyReports,
  then switch to `Deny`.
- **Reports are next to the resource:** a Pod's PolicyReport is in the Pod's
  namespace, not in `kyverno`.
- **Expressions return true or false:** the resource is allowed only when every
  `validations[].expression` returns `true`.

## Learn more

- ValidatingPolicy: https://kyverno.io/docs/policy-types/validating-policy/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

> These docs follow the current Kyverno release. This lab uses **v1.19** — if
> you are on a newer version, use the **Select version** menu on kyverno.io.

Next up: **MutatingPolicy** — change resources as they are created.
