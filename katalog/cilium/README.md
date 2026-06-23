# Cilium

<!-- <SD-DOCS> -->

## Overview

Cilium is an open source, cloud native solution for providing, securing and observing network connectivity between workloads, fueled by the eBPF kernel technology. In the Networking Module it is deployed as a DaemonSet running on all nodes plus an operator Deployment, together with the Hubble observability components. Cilium is configured in IPAM Cluster Scope mode.

> [!IMPORTANT]
> The default Cilium configuration targets clusters with less than 200 nodes.

> [!WARNING]
> Make sure the pod CIDR does not conflict with your node network: if they overlap you may lose connectivity between nodes.

## Upstream project

This package is based on the upstream [Cilium][cilium-github].

## Deployment

This package is deployed as part of **Networking Module** when you create a cluster with `furyctl` and `spec.distribution.modules.networking.type` is set to `cilium`.

You can customize it (for example the pod CIDR and the per-node mask size) under `spec.distribution.modules.networking.cilium` in your `furyctl.yaml`. See the [module documentation](../../README.md) and the configuration reference ([KFDDistribution][schema-reference-kfd], [OnPremises][schema-reference-onprem]) for the available options.

<!-- Links -->

[cilium-github]: https://github.com/cilium/cilium
[schema-reference-kfd]: https://docs.sighup.io/docs/reference/kfddistribution#specdistributionmodulesnetworking
[schema-reference-onprem]: https://docs.sighup.io/docs/reference/onpremises#specdistributionmodulesnetworking

<!-- </SD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
