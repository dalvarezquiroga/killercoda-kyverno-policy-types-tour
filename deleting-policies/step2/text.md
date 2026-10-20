# 2 · Completed Jobs, age & propagation

Finished Jobs pile up fast. Let's delete Jobs that have **completed** and are
**older than 30 seconds** — and make sure their Pods go with them.

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

<details><summary>Info: age-based conditions with time.now()</summary>

<br>

Kyverno's CEL libraries add `time.now()`. Subtracting the resource's
`creationTimestamp` gives its age as a `duration`, which you compare against a
threshold. Both conditions must be `true`, so a Job is deleted only when it is
**complete AND old enough**.

We use `30s` so the lab moves fast — in real life you'd pick something like
`duration('24h')`.

</details>

<details><summary>Info: deletionPropagationPolicy</summary>

<br>

It controls what happens to the **dependents** of a deleted resource (a Job's
Pods, a Deployment's ReplicaSets...):

| Value | Effect |
|-------|--------|
| `Background` | Delete the owner now; the garbage collector removes dependents right after |
| `Foreground` | Delete dependents first, then the owner |
| `Orphan` | Delete the owner only; dependents are left behind |

If you leave it out, the API server's default applies — and for `batch/v1`
Jobs that default is **orphan**, so the Job's Pods would stay behind. That's why
this policy sets `Background` explicitly.

</details>

<br>

Run a short Job in `demo` and wait for it to complete:

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

Now wait for the policy to remove it (the Job must be older than 30s **and** the
next scheduled run must come around — up to about two minutes):

```
kubectl wait --for=delete job/hello-job -n demo --timeout=180s
```{{exec}}

Thanks to `Background` propagation, the Job's Pod is gone too (give it a few
seconds if it is still terminating):

```
kubectl get jobs,pods -n demo
```{{exec}}

<details><summary>Info: NamespacedDeletingPolicy</summary>

<br>

`DeletingPolicy` is cluster-scoped. Its sibling **`NamespacedDeletingPolicy`**
(short name `ndpol`) has the same fields but lives in a namespace and only
deletes resources in that namespace — handy for letting namespace owners
manage their own cleanup without cluster-admin rights.

</details>

<details><summary>Tip: native TTL vs DeletingPolicy</summary>

<br>

Kubernetes has a built-in `spec.ttlSecondsAfterFinished` for Jobs — but only if
every Job author remembers to set it. A DeletingPolicy enforces cleanup
**centrally**, for any kind, with any condition you can write in CEL.

</details>

Click **CHECK** once `hello-job` and its Pod are gone.
