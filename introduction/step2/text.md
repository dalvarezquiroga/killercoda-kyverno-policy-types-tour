# 2 · The parts of Kyverno

> **Docs:** [How Kyverno works](https://kyverno.io/docs/introduction/how-kyverno-works/)

The docs describe Kyverno with a few logical parts. This is where you find
each one in your cluster:

| Part (from the docs) | What it does | Where it runs |
|----------------------|--------------|---------------|
| **Webhook** | Receives requests from the API server | admission controller |
| **Engine** | Applies the policies to each request | admission controller (and the others) |
| **Webhook Controller** | Keeps the webhook configuration up to date with your policies | admission controller |
| **Cert Renewer** | Creates and renews the webhook's TLS certificates | admission controller |
| **Background Controller** | Generates resources and changes existing ones | background controller |
| **Report Controllers** | Build the PolicyReports | reports controller |

The cleanup controller (for DeletingPolicies) is the fourth Deployment you saw
in Step 1.

## Policies are Kubernetes resources

Kyverno adds its own resource types to Kubernetes with **CRDs** (Custom
Resource Definitions). List the Kyverno policy types:

```
kubectl api-resources | grep kyverno
```{{exec}}

The `policies.kyverno.io` group has the CEL-based policy types you will learn
in this course: `ValidatingPolicy`, `MutatingPolicy`, `GeneratingPolicy`,
`DeletingPolicy`, `PolicyException`, and more. The `kyverno.io` group has the
older types, like `ClusterPolicy`, that are deprecated (still working, but no
longer recommended).

Now list all the CRDs that the chart installed, including the reports:

```
kubectl get crd | grep -E "kyverno|wgpolicyk8s"
```{{exec}}

The `policyreports.wgpolicyk8s.io` and `clusterpolicyreports.wgpolicyk8s.io`
CRDs are for the **PolicyReports** — the place where Kyverno records results.

## The certificates

The API server only talks to webhooks over **TLS**. Kyverno's Cert Renewer
creates the certificates and stores them in Secrets:

```
kubectl get secrets -n kyverno
```{{exec}}

Look for `kyverno-svc.kyverno.svc.kyverno-tls-ca` (the certificate authority)
and `kyverno-svc.kyverno.svc.kyverno-tls-pair` (the webhook's certificate).
The cleanup controller has its own pair, because it runs its own webhook.

Click **CHECK** to continue.
