# Well done!

Here's what you learned today — the CEL-based **GeneratingPolicy**:

- Generated a ConfigMap for every new Namespace, and saw **synchronize**
  restore it after you deleted it.
- Generated a ResourceQuota, and learned the **RBAC problem** of the
  background controller.
- And you wrote your own policy to add a **default-deny NetworkPolicy** to
  every new Namespace.

## Tips & common mistakes

- **RBAC first:** the background controller needs an aggregated ClusterRole
  (label `rbac.kyverno.io/aggregate-to-background-controller: "true"`) for
  every kind you generate. Without it, generation fails and you see no error.
- **Generation is asynchronous:** Kubernetes accepts the trigger right away;
  the new resource appears a moment later.
- **It runs on CREATE:** generation runs when the trigger is created. Kyverno
  does not generate resources for Namespaces that already exist, unless the
  policy is applied again.
- **synchronize keeps it in place:** with `synchronize.enabled: true`, Kyverno
  undoes any edit or delete of the generated resource.

## Learn more

- GeneratingPolicy: https://kyverno.io/docs/policy-types/generating-policy/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

> These docs follow the current Kyverno release. This lab uses **v1.19** — if
> you are on a newer version, use the **Select version** menu on kyverno.io.

That's the trio — **Validate**, **Mutate**, **Generate**. You're ready to write
CEL-based Kyverno policies!

Next up: **DeletingPolicy** — clean up resources on a schedule.

Want to keep learning? Follow the [Kyverno blog](https://kyverno.io/blog/) for
new features, examples and real use cases.
