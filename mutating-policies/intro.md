<img src="./mutating-policy.svg" alt="Kyverno MutatingPolicy" width="100%">

<br>

# MutatingPolicy — change resources as they are created

A **MutatingPolicy** (API group `policies.kyverno.io/v1`) changes (patches)
resources when Kubernetes receives them: it can add labels, default values,
security settings, and more. You write the patches in CEL, usually with
`patchType: ApplyConfiguration` — an `Object` that is easy to read and is
merged into the resource.

In this hands-on lab you will learn:

| You'll learn | Concept |
|--------------|---------|
| Patches that merge | `patchType: ApplyConfiguration` |
| Build partial objects | `Object{ ... }` in CEL |
| Set a default only when it's missing | conditional CEL expressions |
| Add security defaults | `spec.securityContext` |
| Do it yourself | a final **challenge** you solve in the terminal |

## Setup

Kyverno **v1.19** is being installed in the background, so the stable
`policies.kyverno.io/v1` CRDs are ready. Wait for the short progress indicator
in the terminal to finish, then click **START**.
