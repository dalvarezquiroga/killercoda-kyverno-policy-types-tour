# 3 · Challenge — default-deny NetworkPolicy

A great real-world use of GeneratingPolicy: give every new Namespace a
**default-deny** NetworkPolicy so nothing talks to anything until you explicitly
allow it.

**Goal:** a `GeneratingPolicy` that creates a NetworkPolicy named `default-deny`
in every new Namespace, selecting all Pods and denying both Ingress and Egress.

A starter file is waiting at **`~/challenge.yaml`** — open it in the editor on
the left, complete the TODO template, then apply it:

```
kubectl apply -f ~/challenge.yaml
```{{exec}}

Trigger it with a fresh Namespace:

```
kubectl create namespace demo-netpol
```{{exec}}

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
- Generation is asynchronous — give it a few seconds.

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
        operations: ["CREATE"]
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

</details>

Click **CHECK** once the NetworkPolicy exists in `demo-netpol`.
