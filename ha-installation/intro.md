<img src="./ha-installation.svg" alt="Kyverno High Availability" width="100%">

<br>

# Kyverno in High Availability

Kyverno sits in the path of **every** API request it has policies for. Its
webhooks fail **closed** by default, so if Kyverno is down, matching requests
are rejected. In production it must survive a crashed Pod, a node drain or an
upgrade — that means running it in **high availability**.

A default install runs four Deployments with **one replica each**. In this
guided lab you will:

| You'll learn | Concept |
|--------------|---------|
| Install Kyverno in HA | per-controller `replicas` with Helm |
| Spread replicas across nodes | pod anti-affinity |
| Who does the work | active/active vs leader election (Leases) |
| Survive voluntary disruptions | PodDisruptionBudgets |
| Prove it | a failure drill: kill the leader, keep enforcing |

## Setup

This lab runs on **two nodes** (`controlplane` and `node01`). Kyverno is **not**
installed yet — you install it yourself in Step 1. The cluster is being
prepared in the background; wait for the short progress indicator in the
terminal to finish, then click **START**.

> Lab only: the control-plane node accepts regular workloads here, so there are
> two nodes to spread across. In production, run Kyverno on dedicated worker
> nodes — ideally three or more, across zones.
