# 1 · Install Kyverno in HA

> **Docs:** [High Availability installation](https://kyverno.io/docs/installation/installation/#high-availability-installation)

First, look at the cluster — two nodes, both ready to run workloads:

```
kubectl get nodes -o wide
```{{exec}}

<br>

Kyverno has **four controllers**, and each one is a separate Deployment. In HA
you set the number of replicas **for each controller**. Install Kyverno
**v1.19** (chart `3.9.1`) with the replica numbers from the docs:

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

This takes a few minutes: `--wait` only finishes when every replica is ready.

<details><summary>Info: why these numbers?</summary>

<br>

| Controller | Replicas | Why |
|------------|----------|-----|
| Admission | 3 | **Every** replica answers webhook requests. More replicas means it stays available **and** can handle more requests. Three is the minimum the HA guide recommends. |
| Background | 2 | Runs generate and mutate-existing policies. One leader does the work; the other is a backup, ready to take over. |
| Cleanup | 2 | Runs DeletingPolicies. The leader does the deleting; the backup takes over if it fails. |
| Reports | 2 | Creates PolicyReports. One leader, one backup. |

</details>

<br>

Check the four Deployments — `READY` should match the number of replicas:

```
kubectl get deploy -n kyverno
```{{exec}}

<details><summary>Tip: the same install as a values file</summary>

<br>

In a real cluster you would keep this in Git instead of a long command:

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

and install it with `helm install kyverno kyverno/kyverno -n kyverno --create-namespace -f values.yaml`.

</details>

Click **CHECK** when every Deployment is fully ready.
