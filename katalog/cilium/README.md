# Cilium

<!-- <KFD-DOCS> -->

**Cilium** is an open source, cloud native solution for providing, securing, and observing network connectivity between
workloads, fueled by the revolutionary Kernel technology eBPF.

> For more information about Cilium refer to [cilium documentation][cilium-documentation]

The deployment of Cilium consists of a DaemonSet running on all nodes, and a operator Deployment.
Additionally, we deploy hubble component as an observability tool on the network connections between pods in the cluster.

> ⚠️ please notice that the Cilium package is for cluster with less than 200 nodes.

## Image repository and tag

- cilium images:
  - `registry.sighup.io/fury/cilium/cilium`
  - `registry.sighup.io/fury/cilium/operator-generic`
  - `registry.sighup.io/fury/cilium/hubble-ui-backend`
  - `registry.sighup.io/fury/cilium/hubble-ui`
  - `registry.sighup.io/fury/cilium/hubble-relay`

## Requirements

- Kubernetes >= `1.29.X`.
- Kustomize >= `v5.6.0`.
- [prometheus-operator from SD monitoring module][prometheus-operator]
- [cert-manager from SD ingress module][cert-manager]

## Configuration

The Cilium package is deployed with the following configuration:

- Cilium configured in IPAM Cluster Scope [The default one](https://docs.cilium.io/en/v1.13/network/concepts/ipam/cluster-pool/)
- Default pod CIDR: 10.0.0.0/8
- Default netmask per node: 24

> :warning: Make sure to change the Default pod CIDR if it's conflicting with your network otherwise if your node network is in
> the same range you will lose connectivity to other nodes.

To change the default pod CIDR you can use the following kustomize patch:

`kustomization.yaml`
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: kube-system

configMapGenerator:
  - name: cilium-config
    behavior: merge
    namespace: kube-system
    envs:
      - patches/cilium-cidr.env
```
`patches/cilium-cidr.env`
```dotenv
cluster-pool-ipv4-cidr=10.100.0.0/8
cluster-pool-ipv4-mask-size=24
```

> :info: The CIDR used by Cilium can be different than the one used by Kubeadm.

## Architecture and Customizations

The Cilium package includes two main variants:

### Core Package (`core/`)
- Base Cilium CNI installation
- Cilium operator for managing network policies
- ServiceMonitors for Prometheus integration

### Hubble Package (`hubble/`)
- Includes everything from core
- Adds Hubble observability components (relay, UI)
- **Minimal customizations** as of v1.18.1:
  - **Grafana dashboard** - Custom dashboard for network metrics visualization
  - **cert-manager Issuer** - Required for TLS certificate generation
  - **Hubble configuration** - Additional settings via ConfigMapGenerator

> **Note**: Starting from v1.18.1, upstream Cilium has resolved many issues we previously patched. The package now requires no custom patches and only adds essential monitoring and PKI resources.

## Deployment

You can deploy Cilium by running the following command in the root of this package:

```bash
kustomize build . | kubectl apply -f -
```

If you want to install Cilium without hubble, use the following command from the root of this package:

```bash
kustomize build core | kubectl apply -f -
```

<!-- LINKS -->
[cilium-documentation]: https://docs.cilium.io/en/stable/
[prometheus-operator]: https://github.com/sighup-io/fury-kubernetes-monitoring/blob/master/katalog/prometheus-operator
[cert-manager]: https://github.com/sighup-io/fury-kubernetes-ingress/blob/master/katalog/cert-manager

<!-- </KFD-DOCS> -->

## License

For license details please see [LICENSE](./../../LICENSE)
