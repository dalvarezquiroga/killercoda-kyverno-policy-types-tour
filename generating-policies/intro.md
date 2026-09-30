<img src="./generating-policy.svg" alt="Kyverno GeneratingPolicy" width="100%">

# GeneratingPolicy — create resources from a trigger

A **GeneratingPolicy** (API group `policies.kyverno.io/v1`) creates or keeps
resources in sync in response to a trigger — for example, giving every new
Namespace a default ConfigMap, quota, or NetworkPolicy. Downstream resources are
authored as YAML templates with CEL placeholders `(( ... ))`.

In this hands-on deep dive you will:

| You'll learn | Concept |
|--------------|---------|
| Create on a trigger | `matchConstraints` on Namespaces |
| Keep resources in sync | `evaluation.synchronize.enabled` |
| Template with live data | CEL `variables` + `(( ... ))` |
| The #1 gotcha | RBAC for the background controller |
| Do it yourself | a final **challenge** you solve in the IDE |

## Setup

Kyverno **v1.19** is being installed in the background, and the background
controller is granted the extra RBAC these steps need. Wait for the short
progress indicator in the terminal to finish, then click **START**.
