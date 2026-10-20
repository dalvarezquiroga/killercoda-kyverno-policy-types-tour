# Kyverno Policy Types Tour

Interactive [Killercoda](https://killercoda.com/) scenarios that teach the new
**CEL-based Kyverno policy types** from the `policies.kyverno.io/v1` API group:
`ValidatingPolicy`, `MutatingPolicy`, `GeneratingPolicy`, `DeletingPolicy` and
`PolicyException` — and how to run Kyverno in **high availability**.

## Scenarios

A course in six parts. Each one is a hands-on lab in the terminal, with guided
steps that are checked for you. The policy scenarios end with a **challenge**
you solve yourself (with Tip and Solution hints if you need help). The HA
scenario ends with a failure test.

| Scenario | What you learn |
|----------|----------------|
| [`validating-policies`](./validating-policies) | Allow, audit or warn on resources with `ValidatingPolicy`: `Deny` / `Audit` / `Warn`, safe CEL, dynamic messages, PolicyReports. Challenge: block the `:latest` tag. |
| [`mutating-policies`](./mutating-policies) | Change resources as they are created with `MutatingPolicy`: `ApplyConfiguration` patches and conditional defaults. Challenge: add `runAsNonRoot`. |
| [`generating-policies`](./generating-policies) | Create resources from a trigger with `GeneratingPolicy`: synchronize, CEL templates, and the background controller RBAC problem. Challenge: a default-deny NetworkPolicy. |
| [`deleting-policies`](./deleting-policies) | Clean up resources on a schedule with `DeletingPolicy`: cron schedules, CEL conditions with `time.now()`, propagation, and the cleanup controller RBAC problem. Challenge: delete ConfigMaps with an `expired` label. |
| [`policy-exceptions`](./policy-exceptions) | Let specific resources skip a CEL policy with `PolicyException`: `policyRefs`, `matchConditions`, `skip` reports, the allowed exceptions namespace, `expiresAt`. Challenge: skip a whole namespace. |
| [`ha-installation`](./ha-installation) | Install Kyverno in high availability on a 2-node cluster: replicas per controller, anti-affinity, leader election Leases, PodDisruptionBudgets, and a failure test. |

Each scenario uses a fixed Kyverno version (**v1.19**, chart `3.9.1`) on a
single-node Kubernetes cluster. The exception is `ha-installation`: it runs on
two nodes, and you install Kyverno yourself. Docs links point to the current
Kyverno release — if you are on a newer one, use the *Select version* menu on
kyverno.io.

## Run on Killercoda

These scenarios are published on my Killercoda profile:
**https://killercoda.com/dalvarezquiroga**

## Author

**David Álvarez Quiroga** — [GitHub](https://github.com/dalvarezquiroga)

## Copyright

© 2026 David Álvarez Quiroga. All rights reserved.

This material is published for hands-on learning on Killercoda. You may not copy,
redistribute, republish, or create derivative works from it, in whole or in part,
without prior written permission from the author. Requests are welcome — open an
issue or reach out on GitHub.
