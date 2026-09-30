# 2 · Report with Audit

Blocking is not always what you want. Switch the **same** policy to `Audit`:
non-compliant Pods are admitted, but every violation is recorded in a
**PolicyReport**.

```
kubectl patch validatingpolicy require-team-label --type=json \
  -p='[{"op":"replace","path":"/spec/validationActions","value":["Audit"]}]'
```{{exec}}

Create a Pod without the `team` label — this time it is **allowed**:

```
kubectl run nginx-audit --image=nginx
```{{exec}}

Pods from `kubectl run` land in the `default` namespace, and Kyverno records the
report right there:

```
kubectl get policyreport -n default
```{{exec}}

Look at the failing entry in detail:

```
kubectl get policyreport -n default -o yaml | grep -A5 require-team-label
```{{exec}}

<details><summary>Tip: where PolicyReports live</summary>

<br>

A PolicyReport is created **in the same namespace as the resource** it describes
— not in the `kyverno` namespace. Cluster-scoped resources use a
`ClusterPolicyReport` instead. Reports are produced by the **reports
controller** and may take a few seconds to appear.

</details>

Click **CHECK** once the PolicyReport exists.
