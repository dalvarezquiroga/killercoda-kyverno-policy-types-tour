# 3 · Governance: namespace & expiry

An exception is a hole in a policy, so **who** can create one — and for how
long — matters as much as the policy itself.

## Only one namespace counts

This cluster accepts exceptions **only** from the `exceptions` namespace. What
happens if someone creates one somewhere else? Try it in `default`, for a Pod
called `batch-runner`:

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: allow-batch-runner
  namespace: default
spec:
  policyRefs:
    - name: require-team-label
      kind: ValidatingPolicy
  matchConditions:
    - name: only-batch-runner
      expression: "object.metadata.name == 'batch-runner'"
EOF
```{{exec}}

The API server **accepts** it, with no warning. But does it work? Test with a
server-side dry-run (admission runs, nothing is created):

```
kubectl run batch-runner --image=nginx --dry-run=server
```{{exec}}

Still **blocked** — Kyverno only reads exceptions from the allowed namespace;
anything elsewhere is **silently ignored**. Remove it:

```
kubectl delete policyexceptions.policies.kyverno.io allow-batch-runner -n default
```{{exec}}

<details><summary>Info: turning the namespace into an approval gate</summary>

<br>

On its own, the namespace setting just tells Kyverno where to look. Combine it
with **RBAC** — only a small group (say, the platform team or your GitOps
pipeline) may create `policyexceptions.policies.kyverno.io` in `exceptions` —
and every exception in the cluster now goes through an approval step.

</details>

<br>

## Time-boxed, documented exceptions

A good exception says **why** it exists and **when** it ends:

- `expiresAt` — an RFC 3339 date-time after which Kyverno no longer applies it.
- `properties` — free-form metadata for reviewers and audits (reason, ticket,
  approver...).

Create the exception properly this time — in `exceptions`, expiring in 30 days:

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: allow-batch-runner
  namespace: exceptions
spec:
  expiresAt: "$(date -u -d '+30 days' +%Y-%m-%dT%H:%M:%SZ)"
  properties:
    reason: "batch-runner is being migrated to the new labels"
    ticket: "OPS-1234"
    approved-by: "platform-team"
  policyRefs:
    - name: require-team-label
      kind: ValidatingPolicy
  matchConditions:
    - name: only-batch-runner
      expression: "object.metadata.name == 'batch-runner'"
EOF
```{{exec}}

```
kubectl get policyexceptions.policies.kyverno.io allow-batch-runner -n exceptions -o yaml
```{{exec}}

Now the dry-run is **allowed**:

```
kubectl run batch-runner --image=nginx --dry-run=server
```{{exec}}

<details><summary>Info: clean up expired exceptions</summary>

<br>

Kyverno ignores an exception once `expiresAt` has passed, but the object itself
stays in the cluster. Kyverno checks the date when it (re)loads a policy and its
exceptions, so don't let expired ones linger — delete them. A **DeletingPolicy**
can do it for you, for example every hour:

```
apiVersion: policies.kyverno.io/v1
kind: DeletingPolicy
metadata:
  name: cleanup-expired-exceptions
spec:
  schedule: "0 * * * *"
  matchConstraints:
    resourceRules:
      - apiGroups: ["policies.kyverno.io"]
        apiVersions: ["v1"]
        resources: ["policyexceptions"]
  conditions:
    - name: is-expired
      expression: >
        has(object.spec.expiresAt) &&
        timestamp(object.spec.expiresAt) < time.now()
```

Remember the cleanup controller also needs RBAC to delete
`policyexceptions` (see the DeletingPolicy scenario).

</details>

Click **CHECK** once `batch-runner` is allowed by an exception in `exceptions`.
