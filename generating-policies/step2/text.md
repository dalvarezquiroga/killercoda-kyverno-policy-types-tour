# 2 · Generate a ResourceQuota (and the RBAC gotcha)

The same template mechanism can generate **any** kind — as long as Kyverno is
allowed to create it. This is the single most common GeneratingPolicy problem.

## The RBAC gotcha

Kyverno's **background controller** creates generated resources. By default it
only has *read* access, so generating a new kind fails silently until you grant
write access. You add it by aggregating a ClusterRole with this label:

```
rbac.kyverno.io/aggregate-to-background-controller: "true"
```

That RBAC was already applied for you during setup (for ConfigMaps,
ResourceQuotas and NetworkPolicies). Take a look:

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

<details><summary>Tip: how to debug a missing generated resource</summary>

<br>

If a generated resource never appears, check the background controller logs and
confirm RBAC:

```
kubectl -n kyverno logs deploy/kyverno-background-controller | grep -i forbidden
```

A `forbidden` error means you are missing an aggregated ClusterRole for that
kind.

</details>

<details><summary>Tip: don't reinvent the wheel — Kyverno sample policies</summary>

<br>

Kyverno publishes a **catalog of ready-made, community-maintained policies** you
can copy and adapt. This exact "quota per namespace" idea is there:
[Add Quota](https://kyverno.io/policies/best-practices-gpol/add-ns-quota/add-ns-quota/)
(it also adds a `LimitRange`).

Browse the whole library at [kyverno.io/policies](https://kyverno.io/policies/).

</details>

Click **CHECK** once the ResourceQuota exists in `demo-quota`.
