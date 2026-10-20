# Well done!

Here's what you learned today — the CEL-based **MutatingPolicy**:

- `patchType: ApplyConfiguration` to merge partial `Object{...}` patches.
- Added a label with a nested `metadata.labels` object.
- Set a default value **only when it was missing**, with a conditional CEL
  expression.
- And you wrote your own policy to add `runAsNonRoot: true`.

## Tips & common mistakes

- **Merge, don't replace:** `ApplyConfiguration` merges your partial object,
  so you never have to write the whole resource again.
- **Check that a field exists:** use `has(object.metadata.labels)` before you
  read from a map that may be missing.
- **Types matter:** `runAsNonRoot: true` is a boolean. If you write `"true"`
  with quotes, it is a string, and that is not the same.
- **CREATE vs UPDATE:** choose when the mutation runs with `operations`. For
  default values, `CREATE` is the usual choice.

## Learn more

- MutatingPolicy: https://kyverno.io/docs/policy-types/mutating-policy/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

> These docs follow the current Kyverno release. This lab uses **v1.19** — if
> you are on a newer version, use the **Select version** menu on kyverno.io.

Next up: **GeneratingPolicy** — create resources from a trigger.
