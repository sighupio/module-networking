# Cilium Package Maintenance Guide

To update the Cilium package with upstream, please follow the next steps.
Image tags are not pinned in `MAINTENANCE.values.yaml`: they follow the chart
version's defaults, so upgrading means rendering with the new chart.

## 1. Compare the helm values with the new chart

`MAINTENANCE.values.yaml` contains only the values that override the chart
defaults. To check your overrides against a new chart version (e.g. `1.19.8`):

```bash
mise run diff-values 1.19.8
```

The task pulls the chart, merges `MAINTENANCE.values.yaml` over its defaults
and shows the effective overrides with `dyff`. Port the changes that are
needed: check that parameters in use are still valid, and drop values that
became chart defaults.

## 2. Render the new manifests

```bash
mise run upgrade-chart 1.19.8
```

The task pulls the chart, renders it with `MAINTENANCE.values.yaml` and
rewrites `resources/deploy.yaml`. Review the changes with `git diff`.

## 3. Run e2e-locally (make sure you have Docker running)

```bash
mise run e2e-cilium
```

> [!NOTE]
> The Kind cluster used for the e2e tests is configured to use kube-proxy in IPVS
> mode, following the default for on-Premises installer.
>
> Check that this is still the case because we are switching to NFTables mode.
>
> See for more details:
>
> - https://github.com/sighupio/installer-on-premises/issues/158
> - https://github.com/sighupio/installer-on-premises/pull/168
> - The `/katalog/tests/kind/config.yml` file

### Expected differences with upstream in the Hubble package

Our customizations are minimal and focused on essential additions:

- **Issuer resources** - Upstream provides Certificate resources but expects the `hubble-issuer` to exist. We provide the Issuer and CA certificate in `resources/pki.yaml`.
