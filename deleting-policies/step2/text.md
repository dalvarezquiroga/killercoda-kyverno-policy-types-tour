# 2 · Delete finished Jobs and their Pods

Finished Jobs stay in the cluster until someone deletes them. Let's delete
Jobs that are **complete** and **older than 30 seconds** — and make sure their
Pods are deleted too.

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: DeletingPolicy
metadata:
  name: cleanup-finished-jobs
spec:
  schedule: "*/1 * * * *"
  deletionPropagationPolicy: Background
  matchConstraints:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: demo
    resourceRules:
      - apiGroups: ["batch"]
        apiVersions: ["v1"]
        resources: ["jobs"]
  conditions:
    - name: is-complete
      expression: >
        object.?status.?conditions.orValue([]).exists(c,
          c.type == 'Complete' && c.status == 'True')
    - name: older-than-30s
      expression: >
        time.now() - timestamp(object.metadata.creationTimestamp) > duration('30s')
EOF
```{{exec}}

<details><summary>Info: conditions based on age, with time.now()</summary>

<br>

Kyverno adds `time.now()` to CEL. If you subtract the resource's
`creationTimestamp` from it, you get the resource's age as a `duration`. Then
you compare it with a limit. Both conditions must be `true`, so a Job is
deleted only when it is **complete AND old enough**.

We use `30s` so the lab is quick. In a real cluster you would use something
like `duration('24h')`.

</details>

<details><summary>Info: deletionPropagationPolicy</summary>

<br>

It controls what happens to the **dependents** of a deleted resource — the
resources it owns, like a Job's Pods or a Deployment's ReplicaSets:

| Value | Effect |
|-------|--------|
| `Background` | Delete the owner now; Kubernetes deletes the dependents right after |
| `Foreground` | Delete the dependents first, then the owner |
| `Orphan` | Delete only the owner; the dependents stay |

If you don't set it, the API server uses its default. For `batch/v1` Jobs that
default is **orphan**, so the Job's Pods would stay. That's why this policy
sets `Background`.

</details>

<br>

Run a short Job in `demo` and wait until it completes:

```
kubectl create job hello-job -n demo --image=busybox -- echo "hello from a job"
```{{exec}}

```
kubectl wait --for=condition=complete job/hello-job -n demo --timeout=90s
```{{exec}}

The Job and its finished Pod are still there:

```
kubectl get jobs,pods -n demo
```{{exec}}

Now wait for the policy to delete it. The Job must be older than 30s **and**
the next scheduled run must happen — this can take up to two minutes:

```
kubectl wait --for=delete job/hello-job -n demo --timeout=180s
```{{exec}}

Because of `Background` propagation, the Job's Pod is deleted too (if it still
shows `Terminating`, wait a few seconds):

```
kubectl get jobs,pods -n demo
```{{exec}}

<details><summary>Info: NamespacedDeletingPolicy</summary>

<br>

`DeletingPolicy` is cluster-scoped. There is also a namespaced version,
**`NamespacedDeletingPolicy`** (short name `ndpol`). It has the same fields,
but it lives in a namespace and only deletes resources in that namespace. This
is useful when namespace owners want to manage their own cleanup without
cluster-admin rights.

</details>

<details><summary>Tip: Kubernetes TTL vs DeletingPolicy</summary>

<br>

Kubernetes has a built-in field for Jobs, `spec.ttlSecondsAfterFinished`, but
it only works if every Job author remembers to set it. A DeletingPolicy applies
the cleanup **in one place**, for any kind, with any condition you can write in
CEL.

</details>

Click **CHECK** when `hello-job` and its Pod are deleted.
