# Kyverno Policy Types Tour

Interactive [Killercoda](https://killercoda.com/) scenarios that teach the modern
**CEL-based Kyverno policy types** from the `policies.kyverno.io/v1` API group:
`ValidatingPolicy`, `MutatingPolicy`, `GeneratingPolicy`, `DeletingPolicy` and
`PolicyException` — plus how to run Kyverno in **high availability**.

## Scenarios

A six-part course. Each one is a terminal-based, hands-on deep dive with guided,
verified steps. The policy scenarios end with a **challenge** you solve yourself
(with Tip and Solution hints if you get stuck); the HA scenario ends with a
failure drill.

| Scenario | What you learn |
|----------|----------------|
| [`validating-policies`](./validating-policies) | Allow, audit or warn on resources with `ValidatingPolicy`: `Deny` / `Audit` / `Warn`, safe CEL, dynamic messages, PolicyReports. Challenge: block the `:latest` tag. |
| [`mutating-policies`](./mutating-policies) | Change resources on the fly with `MutatingPolicy`: `ApplyConfiguration` patches and conditional defaults. Challenge: inject `runAsNonRoot`. |
| [`generating-policies`](./generating-policies) | Create resources from a trigger with `GeneratingPolicy`: synchronize, CEL templates, and the background-controller RBAC gotcha. Challenge: a default-deny NetworkPolicy. |
| [`deleting-policies`](./deleting-policies) | Clean up resources on a schedule with `DeletingPolicy`: cron schedules, CEL conditions with `time.now()`, propagation, and the cleanup-controller RBAC gotcha. Challenge: expire labeled ConfigMaps. |
| [`policy-exceptions`](./policy-exceptions) | Exempt resources from a CEL policy with `PolicyException`: `policyRefs`, `matchConditions`, `skip` reports, the allowed exceptions namespace, `expiresAt`. Challenge: exempt a whole namespace. |
| [`ha-installation`](./ha-installation) | Install Kyverno in high availability on a 2-node cluster: per-controller replicas, anti-affinity, leader election Leases, PodDisruptionBudgets, and a failure drill. |

Each scenario uses a pinned Kyverno (**v1.19**, chart `3.9.1`) on a single-node
Kubernetes cluster — except `ha-installation`, which runs on two nodes and has
you install Kyverno yourself. Docs links follow the current Kyverno release —
use the *Select version* menu on kyverno.io if you're on a newer one.

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
