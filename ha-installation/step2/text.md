# 2 · Replicas, nodes & leaders

> **Docs:** [High Availability guide](https://kyverno.io/docs/guides/high-availability/)

## Spread across nodes

Replicas only help if they don't all die together. See where each Pod landed
(`NODE` column):

```
kubectl get pods -n kyverno -o wide
```{{exec}}

The chart adds a **pod anti-affinity** to every controller, asking the scheduler
to place replicas of the same controller on **different** nodes:

```
kubectl get deploy kyverno-admission-controller -n kyverno -o yaml \
  | grep -A10 podAntiAffinity
```{{exec}}

<details><summary>Info: preferred, not required</summary>

<br>

The rule is `preferredDuringSchedulingIgnoredDuringExecution` — a **soft**
preference. With 3 admission replicas and only 2 nodes, the third replica still
schedules (next to another one) instead of staying `Pending`. With 3+ nodes,
each replica gets its own node. For zone-level resilience you can add
`topologySpreadConstraints` through the chart values.

</details>

<br>

## Who does the work?

Not every controller uses its replicas the same way:

| Controller | Mode |
|------------|------|
| Admission | **Active/active** for webhooks — any replica answers. A single **leader** manages certificates and webhook configurations. |
| Background, Cleanup, Reports | **Active/passive** — one **leader** does the work, the others wait to take over. |

Leaders are chosen with Kubernetes **Leases**. The `HOLDER` column is the name
of the Pod that currently leads:

```
kubectl get leases -n kyverno
```{{exec}}

| Lease | Controller |
|-------|------------|
| `kyverno` | Admission |
| `kyverno-background-controller` | Background |
| `kyverno-cleanup-controller` | Cleanup |
| `kyverno-reports-controller` | Reports |

<br>

Who leads the admission controller right now?

```
kubectl get lease kyverno -n kyverno -o jsonpath='{.spec.holderIdentity}' ; echo
```{{exec}}

Keep that name in mind — in the next step you'll take it down.

Click **CHECK** to continue.
