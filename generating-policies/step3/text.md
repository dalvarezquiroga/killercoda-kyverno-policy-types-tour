# 3 · Challenge — default-deny NetworkPolicy

A great real-world use of GeneratingPolicy: give every new Namespace a
**default-deny** NetworkPolicy so nothing talks to anything until you explicitly
allow it.

**Goal:** a `GeneratingPolicy` that creates a NetworkPolicy named `default-deny`
in every new Namespace, selecting all Pods and denying both Ingress and Egress.

> **Order matters:** generation is **not** retroactive. Because the policy
> matches `CREATE` **and** `UPDATE` on Namespaces, it fires when a Namespace is
> created *or* updated after the policy exists.

Apply your policy first. Then create a Namespace to trigger it:

```
kubectl create namespace demo-netpol
```{{exec}}

```
kubectl get networkpolicy default-deny -n demo-netpol
```{{exec}}

Already created `demo-netpol` **before** applying the policy? Don't recreate it
— just touch it with a label to trigger generation now:

```
kubectl label namespace demo-netpol kyverno-trigger=1 --overwrite
```{{exec}}

Give it a few seconds (generation is asynchronous), then check again:

```
kubectl get networkpolicy default-deny -n demo-netpol
```{{exec}}

<details><summary>Tip</summary>

<br>

- The RBAC for `networkpolicies` was already granted during setup.
- A default-deny NetworkPolicy selects everything and lists both policy types:
  ```
  spec:
    podSelector: {}
    policyTypes:
      - Ingress
      - Egress
  ```
- Keep the `(( variables.nsName ))` placeholder for the target namespace.
- Matching `CREATE` **and** `UPDATE` lets you re-trigger an existing Namespace
  with a label (`kubectl label ns <name> foo=bar --overwrite`).
- Generation is asynchronous — give it a few seconds.
- Prefer a scaffold? A starter file is at `~/challenge.yaml` — edit it
  (`vim ~/challenge.yaml`) and apply with `kubectl apply -f ~/challenge.yaml`.
- Kyverno ships a ready-made version of this exact policy —
  [Add Network Policy](https://kyverno.io/policies/best-practices-gpol/add-network-policy/add-network-policy/)
  from the [policy catalog](https://kyverno.io/policies/). Try it yourself first!

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

Click **CHECK** once the NetworkPolicy exists in `demo-netpol`.
