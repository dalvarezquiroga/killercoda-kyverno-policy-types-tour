# Well done!

Here's what you learned today — the CEL-based **GeneratingPolicy**:

- Generated a ConfigMap for every new Namespace and saw **synchronize** restore
  it after deletion.
- Generated a ResourceQuota, and learned the **RBAC gotcha** for the background
  controller.
- And you wrote your own policy to drop a **default-deny NetworkPolicy** into
  every new Namespace.

## Tips & common pitfalls

- **RBAC first:** the background controller needs an aggregated ClusterRole
  (label `rbac.kyverno.io/aggregate-to-background-controller: "true"`) for every
  kind you generate — otherwise generation fails silently.
- **Generation is async:** the trigger is admitted immediately; the downstream
  resource appears a moment later.
- **Trigger on CREATE:** generation fires when the trigger is created. Existing
  namespaces are not back-filled unless the policy is (re)applied.
- **synchronize keeps it true:** with `synchronize.enabled: true`, edits or
  deletes of the generated resource are reverted.

## Learn more

- GeneratingPolicy: https://kyverno.io/docs/policy-types/generating-policy/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Migration to CEL: https://kyverno.io/docs/guides/migration-to-cel/

> These docs follow the current Kyverno release. This lab targets **v1.19** — if
> you land on a newer version, use the **Select version** menu on kyverno.io.

That's the trio — **Validate**, **Mutate**, **Generate**. You're ready to write
CEL-based Kyverno policies!
