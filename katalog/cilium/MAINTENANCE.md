# Cilium Package Maintenance Guide

To update the Cilium package with upstream, please follow the next steps.

## 0. Check Upstream Improvements (IMPORTANT)

Before starting the update, verify what improvements have been made upstream that might eliminate the need for our patches:

```bash
# Generate upstream manifests with Hubble enabled
helm template cilium /tmp/cilium \
  --namespace kube-system \
  --values MAINTENANCE.values.yaml \
  --set prometheus.serviceMonitor.trustCRDsExist=true \
  > upstream-check.yaml

# Check for previously patched features
grep -i "hubble-metrics" upstream-check.yaml      # Check if metrics port is provided
grep -i "name: hubble-tls" upstream-check.yaml    # Check if TLS volumes are configured
grep -i "cert-manager" upstream-check.yaml        # Check cert-manager integration level
grep -i "kind: Service" upstream-check.yaml | wc -l  # Count services (look for hubble-metrics service)

# Check if ServiceMonitors are properly configured
grep -A 10 "kind: ServiceMonitor" upstream-check.yaml | grep -i hubble

# Document any patches that can be removed based on upstream improvements
```

> 📝 **NOTE**
> If upstream has resolved issues we previously patched, remove the corresponding patches from the `hubble/patches/` directory and update the kustomization.yaml accordingly.

## 1. Updating the values file

1.1. Download the upstream manifests

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
helm search repo cilium/cilium
helm pull cilium/cilium --version 1.18.1 --untar --untardir /tmp
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

## 2. Updating the core package

> ⚠️ **CRITICAL WARNING**: Never include "-generic" in the operator repository name!  
> Helm automatically appends "-generic" suffix based on cloud provider detection (defaults to "generic").  
> 
> **CORRECT**: `registry.sighup.io/fury/cilium/operator`  
> **WRONG**: `registry.sighup.io/fury/cilium/operator-generic`  
> 
> The Helm template at `templates/cilium-operator/_helpers.tpl` line 35 constructs the image as:  
> `printf "%s-%s%s%s%s" repository cloud suffix tag imageDigest`  
> 
> Using `operator-generic` results in: `operator-generic-generic:v1.18.1` which causes ImagePullBackOff!

2.1. Render the manifests from the upstream Chart

```bash
helm template cilium /tmp/cilium \
  --namespace kube-system \
  --values MAINTENANCE.values.yaml \
  --set hubble.enabled=false \
  --set hubble.relay.enabled=false \
  --set hubble.ui.enabled=false \
  --set hubble.metrics.enabled=null \
  --set prometheus.serviceMonitor.trustCRDsExist=true \
  > upstream-without-hubble.yaml
```

2.2. Check the differences between the manifests. Compare `core/deploy.yaml` against `upstream-without-hubble.yaml` and update `deploy.yaml` with the changes from the new version in `upstream-without-hubble.yaml` that need to be included.

```bash
# Compare the full core manifests
dyff between --ignore-whitespace-changes --ignore-order-changes upstream-without-hubble.yaml core/deploy.yaml

# CRITICAL: Focus specifically on ConfigMap changes (most important for functionality)
dyff between --filter="kind=ConfigMap,metadata.name=cilium-config" upstream-without-hubble.yaml core/deploy.yaml

# Check for new or changed configuration parameters
grep -A 100 "kind: ConfigMap" upstream-without-hubble.yaml | grep -E "^  [a-z]" > upstream-config.txt
grep -A 100 "kind: ConfigMap" core/deploy.yaml | grep -E "^  [a-z]" > current-config.txt
diff upstream-config.txt current-config.txt
```

## 3. Updating the hubble package

3.1. Render the manifests from the upstream Chart with Hubble enabled:

```bash
helm template cilium /tmp/cilium \
  --namespace kube-system \
  --values MAINTENANCE.values.yaml \
  --set prometheus.serviceMonitor.trustCRDsExist=true \
  > upstream-with-hubble.yaml
```

3.2. Build the kustomization project for `hubble`:

```bash
kustomize build hubble > local-with-hubble.yaml
```

3.3  Compare the output againts the file `upstream-with-hubble.yaml` to check the differences and port the changes needed to the `hubble` package modifying the `hubble/deploy.yaml` file accordingly.

```bash
# Compare hubble deployments 
dyff between --ignore-whitespace-changes --ignore-order-changes upstream-with-hubble.yaml local-with-hubble.yaml

# Verify hubble config merge worked correctly
dyff between --filter="kind=ConfigMap,metadata.name=cilium-config" upstream-with-hubble.yaml local-with-hubble.yaml
```

### Expected differences with upstream in the Hubble package

As of v1.18.1, our customizations are minimal and focused on essential additions:

- **Grafana dashboards** - Not included in upstream Helm chart. We add them via Kustomize in `monitoring/`.
- **Issuer resources** - Upstream provides Certificate resources but expects the `hubble-issuer` to exist. We provide the Issuer and CA certificate in `resources/pki.yaml`.
- **Hubble configuration** - Additional Hubble settings merged via ConfigMapGenerator in `config/hubble.env`.

> **✅ v1.18.1 Improvements**  
> Upstream has resolved many issues we previously patched:
> - Hubble metrics port (9965) is now included in the DaemonSet
> - Dedicated `hubble-metrics` Service is provided
> - TLS volume mounts are properly configured
> - No patches are currently needed!

> 💡 **TIP**
> You can comment out the monitoring resources in the `core` and `hubble`'s `kustomization.yaml` files in step 3.2 to reduce the number of differences.
> You can also comment out the PKI resources in `hubble`'s `kustomization.yaml` file (resources/pki.yaml) to reduce the number of differences.
>
> Remember to uncomment the Kustomize project before releasing.
