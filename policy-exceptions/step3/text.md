# 3 · Who and until when: namespace & end date

An exception opens a gap in a policy. So it is as important to control **who**
can create one, and **for how long**, as it is to write the policy itself.

## Only one namespace counts

This cluster accepts exceptions **only** from the `exceptions` namespace. What
happens if someone creates one in another namespace? Try it in `default`, for a
Pod called `batch-runner`:

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

The API server **accepts** it, with no warning. But does it work? Test it with
a server-side dry-run (Kyverno checks the request, but nothing is created):

```
kubectl run batch-runner --image=nginx --dry-run=server
```{{exec}}

Still **blocked**. Kyverno only reads exceptions from the allowed namespace. It
ignores all others, and it does not tell you. Delete it:

```
kubectl delete policyexceptions.policies.kyverno.io allow-batch-runner -n default
```{{exec}}

<details><summary>Info: use the namespace as an approval step</summary>

<br>

On its own, the namespace setting only tells Kyverno where to look. Now add
**RBAC**: only a small group (for example the platform team, or your GitOps
pipeline) can create `policyexceptions.policies.kyverno.io` in `exceptions`.
With that, every exception in the cluster needs their approval.

</details>

<br>

## Exceptions with a reason and an end date

A good exception says **why** it exists and **when** it ends:

- `expiresAt` — a date and time (RFC 3339 format). After it, Kyverno no longer
  uses the exception.
- `properties` — any extra information for reviewers and audits (reason,
  ticket, approver...).

Now create the exception the right way — in `exceptions`, with an end date 30
days from now:

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

<details><summary>Info: delete expired exceptions</summary>

<br>

Kyverno stops using an exception after its `expiresAt` date, but the object
stays in the cluster. Kyverno also only checks the date when it (re)loads a
policy and its exceptions. So don't keep expired exceptions — delete them. A
**DeletingPolicy** can do this for you, for example every hour:

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

Remember that the cleanup controller also needs RBAC to delete
`policyexceptions` (see the DeletingPolicy scenario).

</details>

Click **CHECK** when an exception in `exceptions` allows `batch-runner`.
