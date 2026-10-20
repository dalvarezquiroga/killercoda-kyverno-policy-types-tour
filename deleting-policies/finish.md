# Well done!

Here's what you learned today — the CEL-based **DeletingPolicy**:

- Deleted temporary Pods on a **cron schedule**, scoped to one namespace with
  `namespaceSelector` and a CEL **condition**.
- Cleaned up **completed Jobs** older than a threshold with `time.now()`, and
  removed their Pods with `deletionPropagationPolicy: Background`.
- Learned the **RBAC gotcha** for the cleanup controller.
- And you wrote your own policy to expire **ConfigMaps** labeled
  `expired=true`.

## Tips & common pitfalls

- **It really deletes:** scope every DeletingPolicy tightly (namespaces, labels,
  conditions) and try it on a test namespace first.
- **RBAC first:** the cleanup controller needs an aggregated ClusterRole (label
  `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"`) with `delete` on
  every kind you target — otherwise nothing happens, silently.
- **It's scheduled, not instant:** resources go at the next cron tick, not when
  they are created. The minimum interval is one minute.
- **All conditions must be true:** if any condition is `false`, the resource is
  kept. Guard optional fields (`.?labels.?x.orValue('')`) so a condition never
  errors.
- **Mind the dependents:** set `deletionPropagationPolicy` when the target owns
  other resources (Jobs → Pods).

## Learn more

- DeletingPolicy: https://kyverno.io/docs/policy-types/deleting-policy/
- CEL libraries (`time.now()` and friends): https://kyverno.io/docs/policy-types/cel-libraries/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

> These docs follow the current Kyverno release. This lab targets **v1.19** — if
> you land on a newer version, use the **Select version** menu on kyverno.io.

Next up: **PolicyException** — exempt specific resources from a policy, safely.
