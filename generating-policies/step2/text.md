# 2 · Generate a ResourceQuota (and the RBAC problem)

The same template can generate **any** kind — but only if Kyverno is allowed
to create it. This is the most common GeneratingPolicy problem.

## The RBAC problem

Kyverno's **background controller** creates the generated resources. By
default it only has *read* access. So if you generate a new kind, it fails,
and you see no error, until you give it write access. To do that, create a
ClusterRole with this label (an *aggregated* ClusterRole: Kubernetes adds its
rules to the background controller's role):

```
rbac.kyverno.io/aggregate-to-background-controller: "true"
```

The setup already created this ClusterRole for you (for ConfigMaps,
ResourceQuotas and NetworkPolicies). Look at it:

```
kubectl get clusterrole kyverno:generate-extra -o yaml
```{{exec}}

## Generate a ResourceQuota

Give every new Namespace a starter quota:

```
cat <<EOF | kubectl apply -f -
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: generate-default-quota
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
          apiVersion: v1
          kind: ResourceQuota
          metadata:
            name: default-quota
            namespace: (( variables.nsName ))
          spec:
            hard:
              pods: "10"
EOF
```{{exec}}

Trigger it with a new Namespace:

```
kubectl create namespace demo-quota
```{{exec}}

```
kubectl get resourcequota default-quota -n demo-quota
```{{exec}}

<details><summary>Tip: what to check when a generated resource is missing</summary>

<br>

If a generated resource never appears, check the background controller logs
and the RBAC:

```
kubectl -n kyverno logs deploy/kyverno-background-controller | grep -i forbidden
```

A `forbidden` error means that an aggregated ClusterRole for that kind is
missing.

</details>

<details><summary>Tip: use ready-made Kyverno sample policies</summary>

<br>

Kyverno publishes a **catalog of ready-made policies**, maintained by the
community, that you can copy and adapt. This same "quota per namespace" idea
is there:
[Add Quota](https://kyverno.io/policies/best-practices-gpol/add-ns-quota/add-ns-quota/)
(it also adds a `LimitRange`).

See the whole catalog at [kyverno.io/policies](https://kyverno.io/policies/).

</details>

Click **CHECK** when the ResourceQuota exists in `demo-quota`.
