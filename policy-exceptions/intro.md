<img src="./policy-exception.svg" alt="Kyverno PolicyException" width="100%">

<br>

# PolicyException — let resources skip a policy, safely

Policies should cover everyone, but in practice there are always exceptions: an
old app, a Pod for debugging, software from a vendor. A **PolicyException**
(API group `policies.kyverno.io/v1`) lets specific resources **skip** a
specific CEL policy, without changing the policy for everyone else. Kyverno
records the skip in PolicyReports, so it is always visible.

In this hands-on lab you will learn:

| You'll learn | Concept |
|--------------|---------|
| Link an exception to a policy | `spec.policyRefs` |
| Choose exactly which resources skip it | CEL `matchConditions` |
| Where skips appear | PolicyReports (`skip`) |
| Who can create exceptions | the allowed exceptions namespace |
| Exceptions with an end date | `expiresAt` + `properties` |
| Do it yourself | a final **challenge** you solve in the terminal |

## Off by default

PolicyExceptions are **disabled** in a default Kyverno install. In this lab
they are turned on with two Helm values, and Kyverno accepts them **only** from
the `exceptions` namespace:

```
features.policyExceptions.enabled=true
features.policyExceptions.namespace=exceptions
```

## Setup

Kyverno **v1.19** is being installed in the background with PolicyExceptions
turned on, and the `exceptions` and `sandbox` namespaces are created. Wait for
the short progress indicator in the terminal to finish, then click **START**.
