# 1 · Install Kyverno

> **Docs:** [Installation](https://kyverno.io/docs/installation/installation/)

The usual way to install Kyverno is with its **Helm chart**. The setup already
added the Kyverno Helm repository for you:

```
helm search repo kyverno/kyverno
```{{exec}}

<br>

Install Kyverno **v1.19** (chart `3.9.1`) in its own `kyverno` namespace:

```
helm install kyverno kyverno/kyverno \
  -n kyverno --create-namespace \
  --version 3.9.1 \
  --wait --timeout 8m
```{{exec}}

This takes a minute or two: `--wait` only finishes when Kyverno is ready.

<br>

Now look at what was installed:

```
kubectl get deploy,pods -n kyverno
```{{exec}}

You see **four Deployments**. Each one is a separate **controller** with its
own job:

| Deployment | What it does |
|------------|--------------|
| `kyverno-admission-controller` | Checks and changes requests **when they arrive** at the API server |
| `kyverno-background-controller` | Generates resources, and changes resources that already exist |
| `kyverno-cleanup-controller` | Deletes resources on a schedule |
| `kyverno-reports-controller` | Creates the **PolicyReports** with the results |

<details><summary>Info: one replica each</summary>

<br>

This default install runs **one replica** of each controller. That's fine for
a lab. In production you run more replicas, so Kyverno keeps working when a
Pod or a node fails — the `ha-installation` scenario shows how.

</details>

Click **CHECK** when all four Deployments are ready.
