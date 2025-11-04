# Networking Core Module Release vTDB

Welcome to the latest release of the `Networking` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP by ReeVo.

This release updates TBD

## Component Images 🚢

| Component         | Supported Version                                                                | Previous Version |
| ----------------- | -------------------------------------------------------------------------------- | ---------------- |
| `cilium`          | [`v1.18.1`](https://github.com/cilium/cilium/releases/tag/v1.18.1)               | No changes       |
| `tigera-operator` | [`v1.38.6`](https://github.com/tigera/operator/releases/tag/v1.38.6)             | No changes       |

> Please refer the individual release notes to get detailed information on each release.

## Bug fixes 🐞

- [[#101]](https://github.com/sighupio/module-networking/pull/101) **Hubble metrics not being scraped by Prometheus**: fixed and issue with Prometheus not trusting the certficates of the Hubble metrics endpoint, and failing to scrape it in consequence triggering an alert of 100% targets down for the ServiceMonitor.

## Breaking Changes 💔

TBD

## Update Guide 🦮

### Process

1. Just deploy as usual:

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f -
# OR
kustomize build katalog/cilium | kubectl apply -f -
```
