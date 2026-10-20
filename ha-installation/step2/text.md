# 2 · Replicas, nodes & leaders

> **Docs:** [High Availability guide](https://kyverno.io/docs/guides/high-availability/)

## Spread across nodes

Replicas only help if they don't all fail at the same time — for example,
because they all run on the same node. See on which node each Pod is running
(`NODE` column):

```
kubectl get pods -n kyverno -o wide
```{{exec}}

The chart adds a **pod anti-affinity** rule to every controller. It asks the
scheduler to put replicas of the same controller on **different** nodes:

```
kubectl get deploy kyverno-admission-controller -n kyverno -o yaml \
  | grep -A10 podAntiAffinity
```{{exec}}

<details><summary>Info: preferred, not required</summary>

<br>

The rule is `preferredDuringSchedulingIgnoredDuringExecution` — a **soft**
rule: "try to, if possible". With 3 admission replicas and only 2 nodes, the
third replica still starts (on a node that already has one) instead of staying
`Pending`. With 3 or more nodes, each replica gets its own node. To spread
replicas across zones too, you can add `topologySpreadConstraints` in the
chart values.

</details>

<br>

## Who does the work?

The controllers don't all use their replicas in the same way:

| Controller | Mode |
|------------|------|
| Admission | **Active/active** for webhooks — any replica can answer. One **leader** also manages the certificates and the webhook configurations. |
| Background, Cleanup, Reports | **Active/passive** — one **leader** does the work; the others wait, ready to take over. |

Kubernetes **Leases** decide who the leader is. A Lease is a small object that
only one Pod can hold at a time. The `HOLDER` column shows the name of the Pod
that is the leader now:

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

Which Pod is the leader of the admission controller now?

```
kubectl get lease kyverno -n kyverno -o jsonpath='{.spec.holderIdentity}' ; echo
```{{exec}}

Remember that name — in the next step you will delete that Pod.

Click **CHECK** to continue.
