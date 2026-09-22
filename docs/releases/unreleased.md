# Networking Core Module Release 4.1.0

Welcome to the latest release of the `Networking` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP by ReeVo.

This release adds support for Kubernetes 1.36 and officially drops support for Kubernetes versions 1.32.

## Packages version 🚢

| Component         | Current Version                                                      | Previous Version |
|-------------------|----------------------------------------------------------------------|------------------|
| `cilium`          | [`v1.19.8`](https://github.com/cilium/cilium/releases/tag/v1.19.8)   | `v1.18.11`       |
| `tigera-operator` | [`v1.42.6`](https://github.com/tigera/operator/releases/tag/v1.42.6) | `v1.40.13`       |

## Breaking Changes 💔

- **`AdminNetworkPolicy` and `BaselineAdminNetworkPolicy` are no longer supported by Calico.** Calico v3.32 does not install their CRDs and does not enforce these resources. If you use them, migrate to [`ClusterNetworkPolicy`](https://github.com/kubernetes-sigs/network-policy-api) before upgrading.
- **Cilium: `CiliumBGPPeeringPolicy` (BGPv1) API removed, `CiliumLoadBalancerIPPool` `v2alpha1` deprecated.** If you use BGP, migrate to the `cilium.io/v2` APIs (`CiliumBGPClusterConfig`, `CiliumBGPPeerConfig`, `CiliumBGPAdvertisement`) before upgrading. Move custom `CiliumLoadBalancerIPPool` manifests from `apiVersion: cilium.io/v2alpha1` to `cilium.io/v2`.
- **Cilium: deprecated Network Policy fields now rejected, DNS wildcard semantics changed.** Remove `FromRequires`/`ToRequires` from your policies (now enforced empty) and review DNS patterns starting with `**.`, which now match multiple subdomains.

## Update Guide 🦮

### Tigera Calico On Premises

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f -
```

> [!IMPORTANT]
> This release deploys the Calico API Server (new `calico-system/calico-apiserver` pods). Since Calico v3.32 the Goldmane, Whisker and Tiers components use the `projectcalico.org/v3` API served by it, so the `APIServer` resource is now required: without it the operator reports those components as degraded. It is part of `katalog/tigera/on-prem`, so applying the package takes care of it.

### Cilium

Apply the Kustomize project with the new version:

```bash
kustomize build katalog/cilium | kubectl apply -f -
```

> [!IMPORTANT]
> Hubble (deployed together with Cilium) requires cert-manager. If you are using plain `kubectl apply`, resources that require cert-manager (like `Certificate`) may not be deployed on the first pass: re-apply the Cilium package after you've deployed cert-manager so Hubble works.

If you use ClusterMesh together with Network Policies, note that `policy-default-local-cluster` is now `true` by default: selectors without an explicit cluster only select local endpoints. Either update your policies to select remote clusters explicitly or set `policy-default-local-cluster` back to `false`. See the [upstream upgrade notes](https://docs.cilium.io/en/v1.19/operations/upgrade/#current-release-required-changes) for details.
