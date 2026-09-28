Welcome! In this short, hands-on tour you'll meet the three modern
**CEL-based Kyverno policy types** and see each one in action.

Kyverno is a policy engine for Kubernetes. Since 2022 it has fully adopted
**CEL (Common Expression Language)**, the same expression language used by
native Kubernetes admission policies.

In this scenario you will try the three modern, CEL-based policy types
(API group `policies.kyverno.io/v1`):

| Type | What it does |
|------|--------------|
| **ValidatingPolicy** | Allow or block resources (`Deny` / `Audit` / `Warn`) |
| **MutatingPolicy** | Change resources on the fly (add labels, defaults, ...) |
| **GeneratingPolicy** | Create or clone resources from a trigger |

## Why not ClusterPolicy?

The legacy types (`ClusterPolicy`, `Policy`, `CleanupPolicy` and the legacy
`kyverno.io` `PolicyException`) are being retired:

| Release | Date | Status |
|---------|------|--------|
| v1.17 | Feb 2026 | Marked for deprecation |
| v1.18 | Apr 2026 | Critical fixes only |
| v1.19 | Aug 2026 | **Officially deprecated (last release with full support)** |
| v1.20 | Nov 2026 (est.) | **Removed** |

## Setup

Kyverno **v1.19** is being set up for you in the background so the stable
`policies.kyverno.io/v1` CRDs are ready. Wait for the short progress indicator
in the terminal to finish, then click **START**.
