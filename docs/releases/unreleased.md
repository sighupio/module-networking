# Networking Core Module Release TBD

Welcome to the latest release of the `Networking` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP by ReeVo.

## Component Images 🚢

## Bug fixes 🐞

- [[#105]](https://github.com/sighupio/module-networking/pull/105) **Add whisker observability**: enable Calico's Whisker observability UI and its required Goldmane flow aggregator as defaults in the tigera/on-prem package.
- [[#107]](https://github.com/sighupio/module-networking/pull/107) **Fix Calico Grafana dashboard**: "CPU Usage" and "Memory Usage" metrics are now populated.

## Breaking Changes 💔

- [[#109](https://github.com/sighupio/module-networking/pull/109)] **Remove Cilium Core Package**: Cilium previously was provided in two variants: Core and Core+Hubble. The Core variant has been deprecated in favour of keeping a single package Core+Hubble.

## Update Guide 🦮

### Process

#### Tigera Calico On Premises

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f -
```

#### Cilium

> [!NOTE]
> If you were using the `core` only variant of Cilium you will now get the one with Hubble instead.
>
> If you were pointing to the `core` package (`katalog/cilium/core`) or the `hubble` package (`katalog/cilium/hubble`) directly, update the reference to `katalog/cilium`.
>
> See the Breaking changes section for more details.

```bash
kustomize build katalog/cilium | kubectl apply -f -
```
