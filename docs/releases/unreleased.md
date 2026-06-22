# Networking Core Module Release TBD

Welcome to the latest release of the `Networking` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP by ReeVo.

## Component Images 🚢

| Component         | Supported Version                                                                | Previous Version |
| ----------------- | -------------------------------------------------------------------------------- | ---------------- |
| `cilium`          | [`v1.18.11`](https://github.com/cilium/cilium/releases/tag/v1.18.11)             | v1.18.7          |

## Bug fixes 🐞

- [[#105]](https://github.com/sighupio/module-networking/pull/105) **Add whisker observability**: enable Calico's Whisker observability UI and its required Goldmane flow aggregator as defaults in the tigera/on-prem package.
- [[#107]](https://github.com/sighupio/module-networking/pull/107) **Fix Calico Grafana dashboard**: "CPU Usage" and "Memory Usage" metrics are now populated.

## Breaking Changes 💔

- [[#109](https://github.com/sighupio/module-networking/pull/109)] **Remove Cilium Core Package**: Cilium previously was provided in two variants: Core and Core+Hubble. The Core variant has been deprecated in favour of keeping a single package Core+Hubble.
- [[#112](https://github.com/sighupio/module-networking/pull/112)] ConfigMaps holding Grafana Dashboards for Cilium and Hubble (`kube-system/cilium-grafana-dashboard` and `kube-system/hubble-grafana-dashboard`) have been renamed to follow the upstream names.

## Update Guide 🦮

### Tigera Calico On Premises

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f -
```

### Cilium

> [!NOTE]
> If you were using the `core` only variant of Cilium you will now get the one with Hubble instead.
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
