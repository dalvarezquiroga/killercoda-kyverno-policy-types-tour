# 2 · Conditional defaults with CEL

You usually don't want to replace a value that the user already set. A common
pattern is to **set a default only when the value is missing**. With CEL you
can decide the value: keep the current one if it exists, otherwise use a
default.

This policy sets a `tier` label to `backend`, but only if the Pod does not
already have a `tier`:

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-default-tier
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                tier: has(object.metadata.labels) && 'tier' in object.metadata.labels
                  ? object.metadata.labels.tier
                  : "backend"
              }
            }
          }
EOF
```{{exec}}

Create a Pod **without** a `tier` label — it gets the default `backend`:

```
kubectl run nginx-default-tier --image=nginx --labels=team=platform
```{{exec}}

```
kubectl get pod nginx-default-tier -o jsonpath='{.metadata.labels.tier}' ; echo
```{{exec}}

Now create a Pod that **already** has `tier` — its value does not change:

```
kubectl run nginx-frontend --image=nginx --labels=team=platform,tier=frontend
```{{exec}}

```
kubectl get pod nginx-frontend -o jsonpath='{.metadata.labels.tier}' ; echo
```{{exec}}

<details><summary>Info: the conditional expression</summary>

<br>

`has(object.metadata.labels)` first checks that the Pod has labels, so the
expression does not fail when there are none.

The `cond ? a : b` part means: "if the Pod already has a **tier**, keep it;
otherwise use **backend**". `ApplyConfiguration` merges, so writing the same
value back changes nothing. Pods that already have a **tier** stay the same.

</details>

Click **CHECK** when `nginx-default-tier` shows `tier=backend`.
