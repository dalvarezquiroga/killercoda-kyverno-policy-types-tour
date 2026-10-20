# Well done!

Here's what you learned today — running **Kyverno in high availability**:

- Installed Kyverno with per-controller replicas: **3** admission, **2**
  background, **2** cleanup, **2** reports.
- Saw replicas spread across nodes with pod **anti-affinity**.
- Learned which controllers are **active/active** (admission webhooks) and
  which rely on **leader election** (Leases).
- Found the **PodDisruptionBudgets** the chart creates for you.
- And proved it in a failure drill: killed the leader and two of three
  admission replicas, and Kyverno kept enforcing.

## Tips & best practices

- **Three admission replicas minimum:** the admission controller is in the
  request path of the whole cluster — it's the one to scale first.
- **Spread for real:** run on three or more worker nodes, ideally across zones.
  Add `topologySpreadConstraints` when soft anti-affinity is not enough.
- **Keep the PDBs:** they make drains and upgrades safe. Set
  `podDisruptionBudget.enabled=true` explicitly if you prefer a declarative
  config.
- **Fail closed is a choice:** the default protects security, HA protects
  availability. Switch to `forceFailurePolicyIgnore` only on purpose.
- **Watch it:** monitor Kyverno's metrics and webhook latency — slow or missing
  replicas show up there first.

## Learn more

- High Availability guide: https://kyverno.io/docs/guides/high-availability/
- HA installation: https://kyverno.io/docs/installation/installation/#high-availability-installation
- Security vs operability: https://kyverno.io/docs/installation/installation/#security-vs-operability

> These docs follow the current Kyverno release. This lab targets **v1.19** — if
> you land on a newer version, use the **Select version** menu on kyverno.io.

That's the full course — **Validate**, **Mutate**, **Generate**, **Delete**,
**Exceptions** and **High Availability**. You're ready to run Kyverno for real!

Want to keep learning? Follow the [Kyverno blog](https://kyverno.io/blog/) for
new features, patterns and real-world use cases.
