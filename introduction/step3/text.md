# 3 · How a request reaches Kyverno

> **Docs:** [How Kyverno works](https://kyverno.io/docs/introduction/how-kyverno-works/)

Kyverno is a **dynamic admission controller**. When you run `kubectl apply`,
the API server sends the request to Kyverno before it saves anything:

```
kubectl apply
     │
     ▼
API server ──► mutating webhooks ──► validating webhooks ──► saved (etcd)
                     │                        │
                     ▼                        ▼
                  Kyverno                  Kyverno
               (can change it)        (can allow or block it)
```

## The webhook configurations

The API server knows where to send requests because of **webhook
configurations**. Kyverno creates and manages its own:

```
kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations | grep -E "NAME|kyverno"
```{{exec}}

Look at the `WEBHOOKS` column:

- `kyverno-resource-validating-webhook-cfg` and
  `kyverno-resource-mutating-webhook-cfg` have **0** webhooks. There are no
  policies yet, so Kyverno asks the API server to send it nothing.
- `kyverno-policy-validating-webhook-cfg` already has a webhook: Kyverno
  checks your **policies** too, when you create them.

When a webhook can't reach Kyverno, its `failurePolicy` decides what happens:

```
kubectl get validatingwebhookconfiguration kyverno-policy-validating-webhook-cfg \
  -o jsonpath='{.webhooks[*].failurePolicy}' ; echo
```{{exec}}

`Fail` means the webhook **fails closed**: if Kyverno is down, the API server
rejects the request instead of letting it through without a check.

<details><summary>Tip: come back later</summary>

<br>

When you create policies in the next scenarios, the **Webhook Controller**
adds rules to `kyverno-resource-validating-webhook-cfg` — only for the kinds
your policies match. Run the command above again then, and the `WEBHOOKS`
count is no longer 0.

</details>

<br>

## What Kyverno never checks

Kyverno's settings live in the `kyverno` ConfigMap. Two of them keep some
namespaces out of Kyverno's way. The webhooks skip the `kube-system` and
`kyverno` namespaces:

```
kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.webhooks}' ; echo
```{{exec}}

And the **resource filters** list what the Kyverno engine ignores, in the
format `[Kind,Namespace,Name]`:

```
kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.resourceFilters}' ; echo
```{{exec}}

That is why the next scenarios always test policies in your own namespaces,
never in `kube-system`.

<br>

## Not only at admission time

Admission is only half of the story:

- **Background scans:** Kyverno also checks resources that **already exist**,
  for example resources created before a policy.
- **Events:** Kyverno records what it does as Kubernetes events.
- **PolicyReports:** the results of the checks are stored in PolicyReports,
  next to the resources they describe.

<details><summary>Info: Kyverno outside the cluster</summary>

<br>

Kyverno is not only an admission controller:

- The **Kyverno CLI** applies and tests policies on files (Kubernetes
  manifests, Terraform plans...) — useful in CI pipelines.
- The **Authorization Server** uses Kyverno policies to authorize requests for
  your applications (Envoy and HTTP).
- The **Kyverno SDK** lets developers run the Kyverno engine inside their own
  programs.

See [How Kyverno works](https://kyverno.io/docs/introduction/how-kyverno-works/)
for more.

</details>

Click **CHECK** to finish.
