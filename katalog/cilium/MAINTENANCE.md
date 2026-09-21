# Cilium Package Maintenance Guide

To update the Cilium package with upstream, please follow the next steps.

## 1. Update the images

Upgrade all the images running: 
```
mise run upgrade-images <chart_version>
# For example
mise run upgrade-images 1.18.11
```

## 2. Keep the helm-values file updated

`MAINTENANCE.values.yaml` contains only the values that override the chart defaults.
To check your overrides against a new chart version (e.g. `1.19.8`):

```bash
mise run diff-values 1.19.8
```

The task pulls the chart, merges `MAINTENANCE.values.yaml` over its defaults
and shows the effective overrides with `dyff`. Port the changes that are
needed: check that parameters in use are still valid, and drop values that
became chart defaults.

## 3. Updating the Cilium package

3.1. Render the manifests from the upstream Chart with Hubble enabled:

```bash
helm template cilium /tmp/cilium \
  --namespace kube-system \
  --values MAINTENANCE.values.yaml \
  --set prometheus.serviceMonitor.trustCRDsExist=true \
  > upstream.yaml
```

3.2. Compare the file `upstream.yaml` against `resources/deploy.yaml` to check the differences and port the changes needed.

```bash
# Compare hubble deployments 
dyff between --ignore-whitespace-changes --ignore-order-changes resources/deploy.yaml upstream.yaml
```

3.3. Run e2e-locally (make sure you have Docker running):

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
