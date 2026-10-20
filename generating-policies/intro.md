<img src="./generating-policy.svg" alt="Kyverno GeneratingPolicy" width="100%">

<br>

# GeneratingPolicy — create resources from a trigger

A **GeneratingPolicy** (API group `policies.kyverno.io/v1`) creates resources,
and keeps them in sync, when something happens in the cluster (the trigger).
For example, it can give every new Namespace a default ConfigMap, quota, or
NetworkPolicy. You write the resources to create as YAML templates, with CEL
placeholders `(( ... ))`.

In this hands-on lab you will learn:

| You'll learn | Concept |
|--------------|---------|
| Create resources from a trigger | `matchConstraints` on Namespaces |
| Keep resources in sync | `evaluation.synchronize.enabled` |
| Templates with live data | CEL `variables` + `(( ... ))` |
| The most common problem | RBAC for the background controller |
| Do it yourself | a final **challenge** you solve in the terminal |

## Setup

Kyverno **v1.19** is being installed in the background. The setup also gives
the background controller the extra RBAC these steps need. Wait for the short
progress indicator in the terminal to finish, then click **START**.
