# Networking Core Module Release v3.0.0

Welcome to the latest release of the `Networking` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP by ReeVo.

This release updates the Tigera Operator to version 1.38.6, which includes Calico v3.30.3 with official Kubernetes 1.33 support, enhanced GatewayAPI features, and improved testing infrastructure.

## Component Images 🚢

| Component         | Supported Version                                                                | Previous Version |
| ----------------- | -------------------------------------------------------------------------------- | ---------------- |
| `cilium`          | [`v1.17.2`](https://github.com/cilium/cilium/releases/tag/v1.17.2)               | No update        |
| `ip-masq`         | [`v2.8.0`](https://github.com/kubernetes-sigs/ip-masq-agent/releases/tag/v2.8.0) | No update        |
| `tigera-operator` | [`v1.38.6`](https://github.com/tigera/operator/releases/tag/v1.38.6)             | v1.38.0          |

> Please refer the individual release notes to get detailed information on each release.

## Breaking Changes 💔

- None

## Update Guide 🦮

### Process

1. Just deploy as usual:

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f -
# OR
kustomize build katalog/cilium | kubectl apply -f -
```