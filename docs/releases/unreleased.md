# Networking Core Module Release v3.0.0

Welcome to the latest release of the `Networking` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP by ReeVo.

This release updates both the Tigera Operator to version 1.38.6 (Calico v3.30.3) and Cilium to version 1.18.1, providing enhanced networking capabilities, official Kubernetes 1.33 support, improved GatewayAPI features, and robust testing infrastructure.

## Component Images 🚢

| Component         | Supported Version                                                                | Previous Version |
| ----------------- | -------------------------------------------------------------------------------- | ---------------- |
| `cilium`          | [`v1.18.1`](https://github.com/cilium/cilium/releases/tag/v1.18.1)               | v1.17.2          |
| `tigera-operator` | [`v1.38.6`](https://github.com/tigera/operator/releases/tag/v1.38.6)             | v1.38.0          |

> Please refer the individual release notes to get detailed information on each release.

## Breaking Changes 💔

- **REMOVED**: `ip-masq` package has been completely removed from the module. Users requiring IP masquerading functionality should implement their own solution or use CNI-native features.

## Update Guide 🦮

### Process

1. Just deploy as usual:

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f -
# OR
kustomize build katalog/cilium | kubectl apply -f -
```