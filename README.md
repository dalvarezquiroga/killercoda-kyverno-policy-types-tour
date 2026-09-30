# Kyverno Policy Types Tour

Interactive [Killercoda](https://killercoda.com/) scenarios that teach the modern
**CEL-based Kyverno policy types** from the `policies.kyverno.io/v1` API group:
`ValidatingPolicy`, `MutatingPolicy` and `GeneratingPolicy`.

## Scenarios

A three-part course, one scenario per CEL policy type. Each one is a hands-on
deep dive that ends with a **challenge** you solve yourself in the built-in IDE.

| Scenario | What you learn |
|----------|----------------|
| [`validating-policies`](./validating-policies) | Allow, audit or warn on resources with `ValidatingPolicy`: `Deny` / `Audit` / `Warn`, safe CEL, dynamic messages, PolicyReports. Challenge: block the `:latest` tag. |
| [`mutating-policies`](./mutating-policies) | Change resources on the fly with `MutatingPolicy`: `ApplyConfiguration` patches and conditional defaults. Challenge: inject `runAsNonRoot`. |
| [`generating-policies`](./generating-policies) | Create resources from a trigger with `GeneratingPolicy`: synchronize, CEL templates, and the background-controller RBAC gotcha. Challenge: a default-deny NetworkPolicy. |

Each scenario installs a pinned Kyverno (v1.19) on a single-node Kubernetes
cluster and walks you through hands-on, verified steps.

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
