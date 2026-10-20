# Well done!

Here's what you learned today — **what Kyverno is and how it works**:

- Kyverno is a policy engine: you write policies in **YAML and CEL**, and they
  are normal Kubernetes resources.
- Installed Kyverno with **Helm** and met its **four controllers**:
  admission, background, cleanup and reports.
- Found the **CRDs** for the policy types and the PolicyReports, and the
  **certificates** for the webhooks.
- Saw how a request goes from the API server to Kyverno through **admission
  webhooks**, and why they **fail closed** by default.
- Learned what Kyverno never checks (`kube-system`, `kyverno`), and that it
  also scans existing resources in the **background**.

## Tips

- **Use your own namespaces** to test policies — Kyverno ignores
  `kube-system` and `kyverno`.
- **Pin the chart version** (`--version`) so every install is the same.
- **One replica is for labs:** run Kyverno in high availability in
  production.

## Learn more

- Introduction: https://kyverno.io/docs/introduction/
- How Kyverno works: https://kyverno.io/docs/introduction/how-kyverno-works/
- Policy types overview: https://kyverno.io/docs/policy-types/
- Installation: https://kyverno.io/docs/installation/installation/

> These docs follow the current Kyverno release. This lab uses **v1.19** — if
> you are on a newer version, use the **Select version** menu on kyverno.io.

## Join the community

Kyverno is an open source CNCF project, and everybody is welcome:

- **Slack:** the `#kyverno` channel in the Kubernetes workspace —
  https://slack.k8s.io/#kyverno
- **Community meetings:** every two weeks, open to all —
  https://kyverno.io/community/
- **GitHub:** https://github.com/kyverno/kyverno — report bugs, ask for
  features, or contribute.
- **Blog:** https://kyverno.io/blog/ — new features and real use cases.

## What comes next

| Scenario | You learn |
|----------|-----------|
| ValidatingPolicy | Allow, block or warn |
| MutatingPolicy | Change resources as they are created |
| GeneratingPolicy | Create resources from a trigger |
| DeletingPolicy | Delete resources on a schedule |
| PolicyException | Let specific resources skip a policy |
| High Availability | Run Kyverno so it keeps working when something fails |

Next up: **ValidatingPolicy** — allow or block resources.
