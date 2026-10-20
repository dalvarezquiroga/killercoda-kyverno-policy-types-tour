# Well done!

Here's what you learned today — the CEL-based **DeletingPolicy**:

- Deleted temporary Pods on a **cron schedule**, limited to one namespace with
  `namespaceSelector` and a CEL **condition**.
- Deleted **completed Jobs** older than a limit with `time.now()`, and deleted
  their Pods too with `deletionPropagationPolicy: Background`.
- Learned the **RBAC problem** of the cleanup controller.
- And you wrote your own policy to delete **ConfigMaps** with the label
  `expired=true`.

## Tips & common mistakes

- **It really deletes:** limit every DeletingPolicy as much as you can
  (namespaces, labels, conditions), and test it in a test namespace first.
- **RBAC first:** the cleanup controller needs an aggregated ClusterRole (label
  `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"`) with `delete` on
  every kind you want to delete. Without it, nothing happens and you see no
  error.
- **It runs on a schedule, not right away:** resources are deleted at the next
  scheduled run, not when they are created. The shortest interval is one
  minute.
- **All conditions must be true:** if one condition is `false`, the resource
  stays. Read optional fields safely (`.?labels.?x.orValue('')`) so a condition
  never fails.
- **Think about owned resources:** set `deletionPropagationPolicy` when the
  resource owns other resources (Jobs → Pods).

## Learn more

- DeletingPolicy: https://kyverno.io/docs/policy-types/deleting-policy/
- CEL libraries (`time.now()` and more): https://kyverno.io/docs/policy-types/cel-libraries/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

> These docs follow the current Kyverno release. This lab uses **v1.19** — if
> you are on a newer version, use the **Select version** menu on kyverno.io.

Next up: **PolicyException** — let specific resources skip a policy, safely.
