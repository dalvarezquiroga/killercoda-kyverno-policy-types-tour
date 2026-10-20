# 2 · Your first PolicyException

> **Docs:** [Policy Exceptions](https://kyverno.io/docs/guides/exceptions/)

A **PolicyException** has two main parts:

| Field | Purpose |
|-------|---------|
| `policyRefs` | **Which** policy to skip — by `name` and `kind` |
| `matchConditions` | **For which** resources — CEL expressions; all must be `true` |

Let `legacy-app` — and nothing else — skip `require-team-label`. Look at the
namespace: in this lab, Kyverno only accepts exceptions from `exceptions`.

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: allow-legacy-app
  namespace: exceptions
spec:
  policyRefs:
    - name: require-team-label
      kind: ValidatingPolicy
  matchConditions:
    - name: only-legacy-app
      expression: "object.metadata.name == 'legacy-app'"
EOF
```{{exec}}

Now the same command from Step 1 works:

```
kubectl run legacy-app --image=nginx
```{{exec}}

> Still blocked? Kyverno reloads the policy when the exception is created.
> Wait a few seconds and run the command again.

Any **other** Pod without the label is still blocked:

```
kubectl run another-app --image=nginx
```{{exec}}

<br>

## Listing exceptions — careful with the name

There are **two** kinds called `PolicyException`: the CEL one you just used,
and an old, deprecated one from `kyverno.io`. See for yourself:

```
kubectl api-resources | grep -i exception
```{{exec}}

The short name `polex` belongs to the **old** kind. To list the CEL
exceptions, use the full resource name:

```
kubectl get policyexceptions.policies.kyverno.io -A
```{{exec}}

<br>

## The skip is reported

An exception doesn't hide anything. The PolicyReport for `legacy-app` records
a `skip` result with the name of the exception (reports can take a few seconds
to appear):

```
kubectl get policyreport -n default
```{{exec}}

```
kubectl get policyreport -n default -o yaml | grep -B10 -A3 "result: skip"
```{{exec}}

Look for `properties.exceptions: allow-legacy-app`.

<details><summary>Tip: keep match conditions small</summary>

<br>

An exception should match **as few resources as possible**. Matching by name is
a good start. You can combine conditions to make it even more specific, for
example:

```
- name: only-legacy-app-in-default
  expression: >
    object.metadata.name == 'legacy-app' &&
    object.metadata.namespace == 'default'
```

</details>

Click **CHECK** when `legacy-app` is running.
