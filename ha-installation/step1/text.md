# 1 · Install Kyverno in HA

> **Docs:** [High Availability installation](https://kyverno.io/docs/installation/installation/#high-availability-installation)

First, look at the cluster — two nodes, both ready to run workloads:

```
kubectl get nodes -o wide
```{{exec}}

<br>

Kyverno is made of **four controllers**, each its own Deployment. In HA you set
the replica count **per controller**. Install Kyverno **v1.19** (chart `3.9.1`)
with the replica counts from the docs:

```
helm install kyverno kyverno/kyverno \
  -n kyverno --create-namespace \
  --version 3.9.1 \
  --set admissionController.replicas=3 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2 \
  --wait --timeout 8m
```{{exec}}

This takes a few minutes: `--wait` returns only when every replica is ready.

<details><summary>Info: why these numbers?</summary>

<br>

| Controller | Replicas | Why |
|------------|----------|-----|
| Admission | 3 | Serves the webhooks from **every** replica — more replicas give availability **and** throughput. Three is the minimum the HA guide recommends. |
| Background | 2 | Runs generate / mutate-existing. One leader does the work, the other is a hot standby. |
| Cleanup | 2 | Runs DeletingPolicies. Its deletions are done by the leader; the standby takes over on failure. |
| Reports | 2 | Builds PolicyReports. One leader, one standby. |

</details>

<br>

Check the four Deployments — `READY` should match the replica counts:

```
kubectl get deploy -n kyverno
```{{exec}}

<details><summary>Tip: the same install as a values file</summary>

<br>

In real life you'd keep this in Git instead of a long command line:

```
admissionController:
  replicas: 3
backgroundController:
  replicas: 2
cleanupController:
  replicas: 2
reportsController:
  replicas: 2
```

and install with `helm install kyverno kyverno/kyverno -n kyverno --create-namespace -f values.yaml`.

</details>

Click **CHECK** once every Deployment is fully ready.
