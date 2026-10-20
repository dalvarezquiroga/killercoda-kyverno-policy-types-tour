# 3 · PDBs & a failure drill

## PodDisruptionBudgets

Replicas protect you from crashes. **PodDisruptionBudgets** (PDBs) protect you
from *voluntary* disruptions — a `kubectl drain`, a node upgrade, the cluster
autoscaler — by never evicting below a minimum. The chart creates one
automatically for every controller with more than one replica:

```
kubectl get pdb -n kyverno
```{{exec}}

Each one says `MIN AVAILABLE 1`: a drain may evict replicas, but always leaves
at least one running.

<details><summary>Info: PDBs don't stop kubectl delete</summary>

<br>

A PDB only guards the **eviction** API (what `kubectl drain` and autoscalers
use). Deleting a Pod directly — like you are about to do — bypasses it. That's
exactly why you need **replicas** too: PDBs cover planned maintenance, replicas
cover failures.

</details>

<br>

## Something to enforce

Create a policy so you can prove Kyverno keeps working during the drill:

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-team-label
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  validations:
    - message: "label 'team' is required"
      expression: "'team' in object.metadata.?labels.orValue([])"
EOF
```{{exec}}

A server-side dry-run (admission runs, nothing is created) is **blocked**:

```
kubectl run ha-test --image=nginx --dry-run=server
```{{exec}}

<br>

## Drill 1 · Kill the admission leader

Delete the Pod that holds the `kyverno` Lease, and immediately test the policy:

```
LEADER=$(kubectl get lease kyverno -n kyverno -o jsonpath='{.spec.holderIdentity}')
echo "Deleting the admission leader: $LEADER"
kubectl delete pod "$LEADER" -n kyverno --wait=false
kubectl run ha-test --image=nginx --dry-run=server
```{{exec}}

Still **blocked** — the other replicas kept answering webhooks. Give the Lease
a few seconds to expire, then check who leads now:

```
sleep 20; kubectl get leases -n kyverno
```{{exec}}

A **different** Pod holds the `kyverno` Lease: a standby took over certificate
and webhook management.

<br>

## Drill 2 · Lose two of three replicas

Now delete **two** admission replicas at once:

```
kubectl get pods -n kyverno -l app.kubernetes.io/component=admission-controller -o name \
  | head -2 | xargs kubectl delete -n kyverno --wait=false
kubectl run ha-test --image=nginx --dry-run=server
```{{exec}}

Still **blocked** — one replica is enough to keep enforcing. And compliant
requests still go through:

```
kubectl run ha-ok --image=nginx --labels=team=platform --dry-run=server
```{{exec}}

Watch the Deployment heal itself back to three replicas:

```
kubectl rollout status deploy/kyverno-admission-controller -n kyverno --timeout=5m
```{{exec}}

<details><summary>Info: what if ALL replicas are down?</summary>

<br>

Kyverno's webhooks fail **closed** by default: with no replica left, the API
server rejects every request those webhooks match. That's the safe choice for
security, and the reason HA matters.

- The `kyverno` and `kube-system` namespaces are excluded from the webhooks, so
  Kyverno itself can always restart.
- In an emergency you can delete Kyverno's webhook configurations; Kyverno
  recreates them when it comes back.
- `features.forceFailurePolicyIgnore.enabled=true` makes webhooks fail **open**
  instead — more available, less secure. Choose deliberately.

</details>

Click **CHECK** once every Kyverno Deployment is fully ready again.
