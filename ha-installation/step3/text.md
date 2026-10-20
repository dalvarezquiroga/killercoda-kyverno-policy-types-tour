# 3 · PDBs & a failure test

## PodDisruptionBudgets

Replicas protect you when a Pod crashes. **PodDisruptionBudgets** (PDBs)
protect you during *planned* maintenance — a `kubectl drain`, a node upgrade,
the cluster autoscaler. A PDB never lets the number of running replicas go
below a minimum. The chart creates one for every controller with more than one
replica:

```
kubectl get pdb -n kyverno
```{{exec}}

Each one shows `MIN AVAILABLE 1`: a drain can stop replicas, but it always
leaves at least one running.

<details><summary>Info: PDBs don't stop kubectl delete</summary>

<br>

A PDB only protects against **eviction**: the API that `kubectl drain` and
autoscalers use to move Pods away. If you delete a Pod directly — like you
will do now — the PDB does not apply. That's why you need **replicas** too:
PDBs cover planned maintenance, and replicas cover failures.

</details>

<br>

## A policy to test with

Create a policy, so you can check that Kyverno keeps working during the test:

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

A server-side dry-run (Kyverno checks the request, but nothing is created) is
**blocked**:

```
kubectl run ha-test --image=nginx --dry-run=server
```{{exec}}

<br>

## Test 1 · Delete the admission leader

Delete the Pod that holds the `kyverno` Lease, and test the policy right
away:

```
LEADER=$(kubectl get lease kyverno -n kyverno -o jsonpath='{.spec.holderIdentity}')
echo "Deleting the admission leader: $LEADER"
kubectl delete pod "$LEADER" -n kyverno --wait=false
kubectl run ha-test --image=nginx --dry-run=server
```{{exec}}

Still **blocked** — the other replicas kept answering the webhooks. Wait a few
seconds for the Lease to expire, then check who the leader is now:

```
sleep 20; kubectl get leases -n kyverno
```{{exec}}

A **different** Pod holds the `kyverno` Lease: a backup replica took over the
certificates and the webhook configurations.

<br>

## Test 2 · Lose two of three replicas

Now delete **two** admission replicas at the same time:

```
kubectl get pods -n kyverno -l app.kubernetes.io/component=admission-controller -o name \
  | head -2 | xargs kubectl delete -n kyverno --wait=false
kubectl run ha-test --image=nginx --dry-run=server
```{{exec}}

Still **blocked** — one replica is enough to keep the policy working. And
valid requests still work:

```
kubectl run ha-ok --image=nginx --labels=team=platform --dry-run=server
```{{exec}}

Watch the Deployment recover back to three replicas:

```
kubectl rollout status deploy/kyverno-admission-controller -n kyverno --timeout=5m
```{{exec}}

<details><summary>Info: what if ALL replicas are down?</summary>

<br>

By default Kyverno's webhooks **fail closed**: with no replica left, the API
server rejects every request that those webhooks check. This is the safe
choice for security, and it is the reason why HA is important.

- The webhooks don't check the `kyverno` and `kube-system` namespaces, so
  Kyverno itself can always restart.
- In an emergency you can delete Kyverno's webhook configurations. Kyverno
  creates them again when it starts.
- `features.forceFailurePolicyIgnore.enabled=true` makes the webhooks **fail
  open** instead: if Kyverno is down, requests are allowed without checks. More
  available, less secure — only use it on purpose.

</details>

Click **CHECK** when every Kyverno Deployment is fully ready again.
