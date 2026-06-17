# Cilium Package Maintenance Guide

To update the Cilium package with upstream, please follow the next steps.

## 1. Updating the values file

1.1. Download the upstream manifests

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
helm search repo cilium/cilium
helm pull cilium/cilium --version 1.18.7 --untar --untardir /tmp
```

1.2. Compare the `MAINTENANCE.values.yaml` with the one from the chart `/tmp/cilium/values.yaml` and port the changes that are needed. For example, update the image tags and check that parameters that were in use are still valid.

> 💡 **TIP**
> You can use a YAML and Kubernetes-aware tool like [Dyff](https://github.com/homeport/dyff) to compare the files. Dyff will help you to identify the differences between the manifests in a more human-readable way.
>
> ```bash
> # Compare values files to identify what changed upstream
> dyff between --ignore-whitespace-changes --ignore-order-changes /tmp/cilium/values.yaml MAINTENANCE.values.yaml
> 
> # Look specifically for image tags and new/removed configuration options
> dyff between --omit-header /tmp/cilium/values.yaml MAINTENANCE.values.yaml | grep -E "(image|tag|version)"
> ```

## 2. Updating the Cilium package

2.1. Render the manifests from the upstream Chart with Hubble enabled:

```bash
helm template cilium /tmp/cilium \
  --namespace kube-system \
  --values MAINTENANCE.values.yaml \
  --set prometheus.serviceMonitor.trustCRDsExist=true \
  > upstream.yaml
```

2.2. Compare the file `upstream.yaml` against `resources/deploy.yaml` to check the differences and port the changes needed.

```bash
# Compare hubble deployments 
dyff between --ignore-whitespace-changes --ignore-order-changes resources/deploy.yaml upstream.yaml
```

### Expected differences with upstream in the Hubble package

Our customizations are minimal and focused on essential additions:

- **Grafana dashboards** - Not included in upstream Helm chart. We add them via Kustomize in `monitoring/`.
- **Issuer resources** - Upstream provides Certificate resources but expects the `hubble-issuer` to exist. We provide the Issuer and CA certificate in `resources/pki.yaml`.
