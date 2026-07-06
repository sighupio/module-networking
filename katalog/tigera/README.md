# Tigera

<!-- <SD-DOCS> -->

## Overview

The Tigera package provides the Tigera Operator, a Kubernetes Operator that handles the installation and life-cycle of the [Calico][calico-github] CNI. It ships ready-to-go configurations for two scenarios:

- **On-premises**: the operator deploys and configures Calico as the cluster CNI.
- **EKS policy-only mode**: the operator runs only to enforce network policies (the CNI features are disabled), leaving the AWS CNI in place.

## Upstream project

This package is based on the upstream [Calico][calico-github] and its [Tigera Operator][tigera-github].

## Deployment

This package is deployed as part of **Networking Module** when you create a cluster with `furyctl` and `spec.distribution.modules.networking.type` is set to `calico`. The right configuration (on-premises CNI or EKS policy-only mode) is selected automatically based on the cluster.

You can customize it (for example the pod CIDR and block size) under `spec.distribution.modules.networking.tigeraOperator` in your `furyctl.yaml`. See the [module documentation](../../README.md) and the configuration reference ([KFDDistribution][schema-reference-kfd], [OnPremises][schema-reference-onprem]) for the available options.

<!-- Links -->

[calico-github]: https://github.com/projectcalico/calico
[tigera-github]: https://github.com/tigera/operator
[schema-reference-kfd]: https://docs.sighup.io/docs/reference/kfddistribution#specdistributionmodulesnetworking
[schema-reference-onprem]: https://docs.sighup.io/docs/reference/onpremises#specdistributionmodulesnetworking

<!-- </SD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
