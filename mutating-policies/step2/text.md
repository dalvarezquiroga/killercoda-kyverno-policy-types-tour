# 2 · Conditional defaults with CEL

Overwriting a value the user already set is rarely what you want. A common
pattern is **default only when missing**. CEL lets you compute the value
conditionally: keep the existing one if present, otherwise fall back to a
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

Now create a Pod that **already** sets `tier` — its value is preserved:

```
kubectl run nginx-frontend --image=nginx --labels=team=platform,tier=frontend
```{{exec}}

```
kubectl get pod nginx-frontend -o jsonpath='{.metadata.labels.tier}' ; echo
```{{exec}}

<details><summary>Info: the conditional expression</summary>

<br>

`has(object.metadata.labels)` first checks the Pod actually has labels, so the
expression stays safe when there are none.

The `cond ? a : b` part reads as: "if the Pod already has a **tier**, keep it;
otherwise use **backend**". Since `ApplyConfiguration` merges, writing the same
value back changes nothing — so Pods that already set a **tier** are left
untouched.

</details>

Click **CHECK** when `nginx-default-tier` shows `tier=backend`.
