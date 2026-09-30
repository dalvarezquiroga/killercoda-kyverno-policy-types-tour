<img src="./mutating-policy.svg" alt="Kyverno MutatingPolicy" width="100%">

# MutatingPolicy — change resources on the fly

A **MutatingPolicy** (API group `policies.kyverno.io/v1`) patches resources as
they are admitted: inject labels, sensible defaults, security settings, and
more. Patches are written in CEL, most often with `patchType: ApplyConfiguration`
— a readable, merge-style `Object`.

In this hands-on deep dive you will:

| You'll learn | Concept |
|--------------|---------|
| Merge-style patches | `patchType: ApplyConfiguration` |
| Build partial objects | `Object{ ... }` in CEL |
| Default only when missing | conditional CEL expressions |
| Inject security defaults | `spec.securityContext` |
| Do it yourself | a final **challenge** you solve in the IDE |

## Setup

Kyverno **v1.19** is being installed in the background so the stable
`policies.kyverno.io/v1` CRDs are ready. Wait for the short progress indicator
in the terminal to finish, then click **START**.
