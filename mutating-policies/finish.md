# Well done!

Here's what you learned today — the CEL-based **MutatingPolicy**:

- `patchType: ApplyConfiguration` to merge partial `Object{...}` patches.
- Injected a label with a nested `metadata.labels` object.
- Defaulted a value **only when missing** using a conditional CEL expression.
- And you wrote your own policy to inject `runAsNonRoot: true`.

## Tips & common pitfalls

- **Merge, don't replace:** `ApplyConfiguration` merges your partial object, so
  you never have to restate the whole resource.
- **Guard optional maps:** use `has(object.metadata.labels)` before indexing a
  map that may be absent.
- **Types matter:** `runAsNonRoot: true` is a boolean; quoting it as `"true"`
  changes the meaning.
- **CREATE vs UPDATE:** scope mutations with `operations`. Mutating on `CREATE`
  is the common case for defaults.

## Learn more

- MutatingPolicy: https://kyverno.io/docs/policy-types/mutating-policy/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

> These docs follow the current Kyverno release. This lab targets **v1.19** — if
> you land on a newer version, use the **Select version** menu on kyverno.io.

Next up: **GeneratingPolicy** — create resources from a trigger.
