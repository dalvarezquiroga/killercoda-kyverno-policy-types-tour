# 2 · Your first PolicyException

> **Docs:** [Policy Exceptions](https://kyverno.io/docs/guides/exceptions/)

A **PolicyException** has two key parts:

| Field | Purpose |
|-------|---------|
| `policyRefs` | **Which** policy to skip — by `name` and `kind` |
| `matchConditions` | **For which** resources — CEL expressions; all must be `true` |

Exempt `legacy-app` — and nothing else — from `require-team-label`. Note the
namespace: in this lab, exceptions are only accepted from `exceptions`.

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

Now the same command from Step 1 succeeds:

```
kubectl run legacy-app --image=nginx
```{{exec}}

> Still blocked? Kyverno reloads the policy as soon as the exception is created —
> give it a couple of seconds and run the command again.

Any **other** unlabeled Pod is still blocked:

```
kubectl run another-app --image=nginx
```{{exec}}

<br>

## Listing exceptions — mind the name

There are **two** kinds called `PolicyException`: the CEL one you just used,
and the deprecated legacy one from `kyverno.io`. See for yourself:

```
kubectl api-resources | grep -i exception
```{{exec}}

The short name `polex` belongs to the **legacy** kind. Use the full resource
name to list the CEL exceptions:

```
kubectl get policyexceptions.policies.kyverno.io -A
```{{exec}}

<br>

## The skip is reported

An exception doesn't hide anything: the PolicyReport for `legacy-app` records a
`skip` result naming the exception (reports may take a few seconds):

```
kubectl get policyreport -n default
```{{exec}}

```
kubectl get policyreport -n default -o yaml | grep -B10 -A3 "result: skip"
```{{exec}}

Look for `properties.exceptions: allow-legacy-app`.

<details><summary>Tip: write narrow match conditions</summary>

<br>

An exception should match **as little as possible**. Matching by name is a good
start; combine conditions for even tighter scope, for example:

```
- name: only-legacy-app-in-default
  expression: >
    object.metadata.name == 'legacy-app' &&
    object.metadata.namespace == 'default'
```

</details>

Click **CHECK** once `legacy-app` is running.
