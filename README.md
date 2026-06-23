<!-- markdownlint-disable MD033 -->
<h1 align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/black-logo.png">
  <img alt="Shows a black logo in light color mode and a white one in dark color mode." src="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
</picture><br/>
  Networking Module
</h1>
<!-- markdownlint-enable MD033 -->

![Release](https://img.shields.io/badge/Latest%20Release-v4.0.0-blue)
![License](https://img.shields.io/github/license/sighupio/module-networking?label=License)
![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)

<!-- <SD-DOCS> -->

**Networking Module** implements in-cluster networking for [SIGHUP Distribution (SD)][kfd-repo] via Container Network Interface (CNI) plugins.

If you are new to SD please refer to the [official documentation][kfd-docs] on how to get started with SD.

## Overview

Kubernetes adopts the Container Network Interface (CNI) specification for managing network resources on a cluster. **Networking Module** uses the CNCF projects [Calico][tigera-page] (via the Tigera Operator) and [Cilium][cilium-page] — open-source networking and network security solutions for containers, virtual machines and bare-metal workloads — to bring networking capabilities to the distribution.

## Packages

The following packages are included in Networking Module:

| Package                  | Version                     | Description                                                                                                                                          |
| ------------------------ | --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| [cilium](katalog/cilium) | `1.18.11`                   | [Cilium][cilium-page] CNI plugin. For clusters with `< 200` nodes.                                                                                   |
| [tigera](katalog/tigera) | `1.40.13` (Calico `3.31.6`) | [Tigera Operator][tigera-page], a Kubernetes Operator for Calico, provides pre-configured installations for on-prem and for EKS in policy-only mode. |

Click on each package to see its full documentation.

## Compatibility

| Kubernetes Version |   Compatibility    | Notes           |
| ------------------ | :----------------: | --------------- |
| `1.32.x`           | :white_check_mark: | No known issues |
| `1.33.x`           | :white_check_mark: | No known issues |
| `1.34.x`           | :white_check_mark: | No known issues |
| `1.35.x`           | :white_check_mark: | No known issues |

Check the [compatibility matrix][compatibility-matrix] for additional information about previous releases of the module.

## Usage

**Networking Module** is part of SIGHUP Distribution (SD) and is deployed automatically by [`furyctl`][furyctl-repo] when you create or update a `KFDDistribution` or `OnPremises` cluster. You don't need to download, vendor or install its packages manually.

### Configuration

You configure the module under `spec.distribution.modules.networking` in your `furyctl.yaml`. The `type` field selects the CNI plugin to deploy: `calico` (Tigera Operator) or `cilium` (on `KFDDistribution` you can also set `none` when the CNI is managed outside this module). You must also set the pod CIDR for the selected CNI. The other fields are optional and fall back to sensible defaults.

```yaml
apiVersion: kfd.sighup.io/v1alpha2
kind: KFDDistribution
spec:
  distribution:
    modules:
      networking:
        type: calico
        tigeraOperator:
          podCidr: 10.244.0.0/16
```

To use Cilium instead of Calico, set `type: cilium` and configure the `cilium` block:

```yaml
apiVersion: kfd.sighup.io/v1alpha2
kind: KFDDistribution
spec:
  distribution:
    modules:
      networking:
        type: cilium
        cilium:
          podCidr: 10.0.0.0/8
          maskSize: "24"
```

See the configuration reference for your cluster kind for the full list of available options: [KFDDistribution][schema-reference-kfd] or [OnPremises][schema-reference-onprem].

To install SD from scratch, follow the [Getting started][getting-started] guide.

<!-- Links -->

[cilium-page]: https://github.com/cilium/cilium
[tigera-page]: https://github.com/projectcalico/calico
[kfd-repo]: https://github.com/sighupio/distribution
[furyctl-repo]: https://github.com/sighupio/furyctl
[kfd-docs]: https://docs.sighup.io/docs/distribution/
[schema-reference-kfd]: https://docs.sighup.io/docs/reference/kfddistribution#specdistributionmodulesnetworking
[schema-reference-onprem]: https://docs.sighup.io/docs/reference/onpremises#specdistributionmodulesnetworking
[getting-started]: https://docs.sighup.io/docs/getting-started/
[compatibility-matrix]: https://github.com/sighupio/module-networking/blob/main/docs/COMPATIBILITY_MATRIX.md

<!-- </SD-DOCS> -->

<!-- <FOOTER> -->

## Contributing

Before contributing, please read first the [Contributing Guidelines](https://github.com/sighupio/distribution/blob/main/docs/CONTRIBUTING.md).

### Reporting Issues

In case you experience any problem with the module, please [open a new issue](https://github.com/sighupio/module-networking/issues/new/choose).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE).

<!-- </FOOTER> -->
