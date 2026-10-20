# 3 · Challenge — default-deny NetworkPolicy

A very useful, real use of GeneratingPolicy: give every new Namespace a
**default-deny** NetworkPolicy. Then no traffic is allowed until you allow it
yourself.

**Goal:** a `GeneratingPolicy` that creates a NetworkPolicy named
`default-deny` in every new Namespace. It must select all Pods and deny both
Ingress and Egress.

> **Order matters:** generation does **not** apply to Namespaces that already
> exist. The policy matches `CREATE` **and** `UPDATE` on Namespaces, so it runs
> when a Namespace is created *or* updated after the policy exists.

Apply your policy first. Then create a Namespace to trigger it:

```
kubectl create namespace demo-netpol
```{{exec}}

```
kubectl get networkpolicy default-deny -n demo-netpol
```{{exec}}

Did you create `demo-netpol` **before** you applied the policy? Don't create it
again — just add a label to it, so generation runs now:

```
kubectl label namespace demo-netpol kyverno-trigger=1 --overwrite
```{{exec}}

Wait a few seconds (generation is asynchronous), then check again:

```
kubectl get networkpolicy default-deny -n demo-netpol
```{{exec}}

<details><summary>Tip</summary>

<br>

- The setup already gave the background controller RBAC for
  `networkpolicies`.
- A default-deny NetworkPolicy selects all Pods and lists both policy types:
  ```
  spec:
    podSelector: {}
    policyTypes:
      - Ingress
      - Egress
  ```
- Keep the `(( variables.nsName ))` placeholder for the target namespace.
- Matching `CREATE` **and** `UPDATE` lets you trigger an existing Namespace
  again by adding a label (`kubectl label ns <name> foo=bar --overwrite`).
- Generation is asynchronous — wait a few seconds.
- Want a starting point? There is a starter file at `~/challenge.yaml`. Edit it
  (`vim ~/challenge.yaml`) and apply it with `kubectl apply -f ~/challenge.yaml`.
- Kyverno has a ready-made version of this policy —
  [Add Network Policy](https://kyverno.io/policies/best-practices-gpol/add-network-policy/add-network-policy/)
  in the [policy catalog](https://kyverno.io/policies/). But try it yourself
  first!

</details>

<details><summary>Solution</summary>

<br>

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: default-deny-netpol
spec:
  evaluation:
    synchronize:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["namespaces"]
  variables:
    - name: nsName
      expression: "object.metadata.name"
  generate:
    - template:
        interpolate: cel
        value: |
          apiVersion: networking.k8s.io/v1
          kind: NetworkPolicy
          metadata:
            name: default-deny
            namespace: (( variables.nsName ))
          spec:
            podSelector: {}
            policyTypes:
              - Ingress
              - Egress
EOF
```{{exec}}

Then trigger it: `kubectl create namespace demo-netpol`

<br>

Reference: [Kyverno GeneratingPolicy docs](https://kyverno.io/docs/policy-types/generating-policy/).

</details>

Click **CHECK** when the NetworkPolicy exists in `demo-netpol`.
