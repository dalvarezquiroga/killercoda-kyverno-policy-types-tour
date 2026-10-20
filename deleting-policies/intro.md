<img src="./deleting-policy.svg" alt="Kyverno DeletingPolicy" width="100%">

<br>

# DeletingPolicy — clean up resources on a schedule

A **DeletingPolicy** (API group `policies.kyverno.io/v1`) deletes existing
resources on a **cron schedule** when its CEL conditions are true. For example:
temporary Pods, finished Jobs or old ConfigMaps. It does not check new requests
like other policies do. Instead, Kyverno's **cleanup controller** runs on the
schedule, finds the matching resources and deletes them.

In this hands-on lab you will learn:

| You'll learn | Concept |
|--------------|---------|
| Delete on a schedule | `spec.schedule` (cron) |
| Choose exactly what to delete | `matchConstraints` + CEL `conditions` |
| Delete by age | `time.now()` in CEL |
| What happens to owned resources | `deletionPropagationPolicy` |
| The most common problem | RBAC for the cleanup controller |
| Do it yourself | a final **challenge** you solve in the terminal |

## Replaces CleanupPolicy

The old `CleanupPolicy` / `ClusterCleanupPolicy` (`kyverno.io`) are
deprecated in v1.19 (still working, but no longer recommended) and will be
removed in v1.20. `DeletingPolicy` is the new CEL-based replacement.

## Setup

Kyverno **v1.19** is being installed in the background. The setup also gives
the cleanup controller the extra RBAC these steps need, and creates a `demo`
namespace. Wait for the short progress indicator in the terminal to finish,
then click **START**.
