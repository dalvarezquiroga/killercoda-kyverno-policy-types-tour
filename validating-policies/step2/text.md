# 2 · Report with Audit

You don't always want to block. Switch the **same** policy to `Audit`: Pods
that break the rule are allowed, but every violation is recorded in a
**PolicyReport**.

```
kubectl patch validatingpolicy require-team-label --type=json \
  -p='[{"op":"replace","path":"/spec/validationActions","value":["Audit"]}]'
```{{exec}}

Create a Pod without the `team` label — this time it is **allowed**:

```
kubectl run nginx-audit --image=nginx
```{{exec}}

Pods from `kubectl run` go to the `default` namespace, and Kyverno creates the
report in that same namespace:

```
kubectl get policyreport -n default
```{{exec}}

You'll see one row per Pod, for example:

- **nginx-team** (from Step 1, has the label) → `PASS 1`
- **nginx-audit** (no label) → `FAIL 1`

Audit never blocks, but it clearly shows which Pods follow the rule and which
don't. This is useful to measure the impact before you switch a policy to
`Deny`.

Look at the failing entry in detail:

```
kubectl get policyreport -n default -o yaml | grep -A5 require-team-label
```{{exec}}

<details><summary>Tip: where PolicyReports are created</summary>

<br>

A PolicyReport is created **in the same namespace as the resource** it is
about — not in the `kyverno` namespace. Cluster-scoped resources use a
`ClusterPolicyReport` instead. The **reports controller** creates the reports,
and they can take a few seconds to appear.

</details>

Click **CHECK** when the PolicyReport exists.
