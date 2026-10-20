# Well done!

Here's what you learned today — running **Kyverno in high availability**:

- Installed Kyverno with replicas for each controller: **3** admission, **2**
  background, **2** cleanup, **2** reports.
- Saw how pod **anti-affinity** spreads replicas across nodes.
- Learned which controllers are **active/active** (admission webhooks) and
  which use **leader election** (Leases).
- Found the **PodDisruptionBudgets** that the chart creates for you.
- And proved it in a failure test: you deleted the leader and two of three
  admission replicas, and the policy still worked.

## Tips & best practices

- **At least three admission replicas:** the admission controller checks
  requests for the whole cluster — scale it first.
- **Spread replicas for real:** use three or more worker nodes, ideally in
  different zones. Add `topologySpreadConstraints` when the soft anti-affinity
  rule is not enough.
- **Keep the PDBs:** they make drains and upgrades safe. If you want it written
  in your config, set `podDisruptionBudget.enabled=true` yourself.
- **Fail closed is a choice:** the default protects security, and HA protects
  availability. Only switch to `forceFailurePolicyIgnore` on purpose.
- **Monitor it:** watch Kyverno's metrics and webhook latency — slow or missing
  replicas show up there first.

## Learn more

- High Availability guide: https://kyverno.io/docs/guides/high-availability/
- HA installation: https://kyverno.io/docs/installation/installation/#high-availability-installation
- Security vs operability: https://kyverno.io/docs/installation/installation/#security-vs-operability

> These docs follow the current Kyverno release. This lab uses **v1.19** — if
> you are on a newer version, use the **Select version** menu on kyverno.io.

That's the full course — **Validate**, **Mutate**, **Generate**, **Delete**,
**Exceptions** and **High Availability**. You're ready to run Kyverno in a real
cluster!

Want to keep learning? Follow the [Kyverno blog](https://kyverno.io/blog/) for
new features, examples and real use cases.
