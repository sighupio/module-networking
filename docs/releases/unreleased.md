# Networking Core Module Release 4.1.0

Welcome to the latest release of the `Networking` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP by ReeVo.

This release adds support for Kubernetes 1.36 and officially drops support for Kubernetes versions 1.32.

## Packages version 🚢

| Component         | Current Version                                                      | Previous Version |
|-------------------|----------------------------------------------------------------------|------------------|
| `cilium`          | [`v1.18.11`](https://github.com/cilium/cilium/releases/tag/v1.18.11) | `No Update`      |
| `tigera-operator` | [`v1.42.6`](https://github.com/tigera/operator/releases/tag/v1.42.6) | `v1.40.13`       |

## Breaking Changes 💔

- **`AdminNetworkPolicy` and `BaselineAdminNetworkPolicy` are no longer supported by Calico.** Calico v3.32 does not install their CRDs and does not enforce these resources. If you use them, migrate to [`ClusterNetworkPolicy`](https://github.com/kubernetes-sigs/network-policy-api) before upgrading.

## Update Guide 🦮

### Tigera Calico On Premises

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f -
```

> [!IMPORTANT]
> This release deploys the Calico API Server (new `calico-system/calico-apiserver` pods). Since Calico v3.32 the Goldmane, Whisker and Tiers components use the `projectcalico.org/v3` API served by it, so the `APIServer` resource is now required: without it the operator reports those components as degraded. It is part of `katalog/tigera/on-prem`, so applying the package takes care of it.
>
> If you use `AdminNetworkPolicy` or `BaselineAdminNetworkPolicy`, migrate to `ClusterNetworkPolicy` before upgrading (see Breaking Changes).

### Cilium

> [!NOTE]
> If you were using the `core` only variant of Cilium, you will now get the one with Hubble instead.
>
> If you were pointing to the `core` package (`katalog/cilium/core`) or the `hubble` package (`katalog/cilium/hubble`) directly, update the reference to `katalog/cilium`.
>
> See the Breaking changes section for more details.

ConfigMaps holding Grafana Dashboards for Cilium have changed name to use the same as upstream. If you are using `kubectl apply` you need to manually delete the old configmaps before applying the new ones:

```bash
kubectl delete configmap -n kube-system cilium-grafana-dashboard hubble-grafana-dashboard
```

Apply the Kustomize project with the new version:

```bash
kustomize build katalog/cilium | kubectl apply -f -
```

> [!IMPORTANT]
> The new single package introduces a cyclic dependency between Cilium and cert-manager. Hubble (deployed together with Cilium) requires cert-manager, and cert-manager requires at least some nodes to be ready (CNI working) to be scheduled.
>
> You may need to adjust your deployment strategy while switching to the unified package.
>
> For example, if you are using a tool that verifies dependencies (like Carvel `kapp`) you may apply cert-manager and cilium together in the same `kapp deploy` command.
>
> If you are using plain `kubectl apply` instead, you will see some messages saying that the resources that require cert-manager (like `Certificate`, `Issuer`, etc.) are not being deployed. You will need to re-apply the cilium package after you've deployed cert-manager so Hubble works.
