# Tigera Package Maintenance Guide

## Tigera Operator

Tigera operator manifests files are taken as-is from upstream.

Here are the installation notes:
<https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises>

Here are the upgrade considerations:
<https://docs.tigera.io/calico/latest/operations/upgrading/kubernetes-upgrade>

To update the package contents to a specific version from upstream, run the following command:

```bash
mise run maintenance v3.31.6 # Keep this value updated so the next maintainer knows which vesion was used the last time.
```

### Customizations

The Operator is patched via Kustomize to:

- Change the `-manage-crds=true` flag to `-manage-crds=false` in the operator container arguments. We're managing the CRDs ourselves, without relying on the operator to handle them.
- Use the image from SIGHUP's registry.

There's a fake deployment with zero replicas in the `dummy-dictionary-calico-images.yaml` file to get our CVE-patching pipeline to detect these images that don't appear anywhere in the manifests, despite being started by the Tigera Operator.

Keep an eye on [this document](https://docs.tigera.io/calico/latest/operations/image-options/imageset#create-an-imageset) to have an idea of the needed images.

## On-premises

For managed on-premises installations, in addition to the operator, you need to create a custom resource with the CNI configuration.

Our CNI configuration file (`on-prem/custom-resources.yaml`) has been generated starting from an example from Tigera.

Here is the documentation
<https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises>

If you need for some reason to download the default configuration from upstream, use the following commands:

```bash
# assuming katalog/tigera is the root of the repository
export CALICO_VERSION="3.31.6"
curl https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/custom-resources.yaml --output on-prem/custom-resources.yaml
```

### Customizations

The on-prem example file from upstream has been edited with the following:

- Use SIGHUP's registry
- Deleted the `calicoNetwork` section included in the upstream configuration file, the Operator should detect the CIDR from the cluster's installation and set it accordingly.
- Calico ApiServer is not deployed by default by our installation.

### Monitoring

There are some custom headless services and service monitors defined as part of the kustomize project for the on-prem variant.

The custom files have been created following the official documentation: [Monitor Calico component metrics](https://docs.tigera.io/calico/latest/operations/monitor/monitor-component-metrics)

The dashboards are the official ones with some minor tuning for the Prometheus datasource. They are updated automatically as part of the `maintenance` mise task.

> [!TIP]
> Check that there are no new dashboards included upstream that may need to be added to the maintenance task,

#### ServiceMonitor job label

The upstream Typha dashboard queries metrics with `job="typha_metrics"`. The ServiceMonitor in `monitoring/sm.yaml` uses `jobLabel: k8s-app` which produces `job="calico-typha"`. A relabeling override is applied to fix this:

```yaml
relabelings:
  - targetLabel: job
    replacement: typha_metrics
```

When updating, verify the relabeling is still present on the calico-typha ServiceMonitor.

#### Alerts

Calico / Tigera upstream does not provide a set of Prometheus Rules that we could include, from [their monitoring documentation](https://projectcalico.docs.tigera.io/maintenance/monitor/monitor-component-metrics) here are the available metrics:

- <https://projectcalico.docs.tigera.io/reference/felix/prometheus>
- <https://projectcalico.docs.tigera.io/reference/kube-controllers/prometheus>
- <https://projectcalico.docs.tigera.io/reference/typha/prometheus>

The alerts included are inspired in Platform9's and Sysdig's, see:

- <https://platform9.com/docs/kubernetes/catapult-rules-alarms#calico>
- <https://platform9.com/docs/kubernetes/calico-monitoring>
- <https://docs.sysdig.com/en/docs/sysdig-monitor/monitoring-integrations/application-integrations/calico/>
- <https://docs.sysdig.com/en/docs/sysdig-monitor/monitoring-integrations/application-integrations/calico/#errors>

You can generate a markdown table with the rules to include it in the Readme file with the following command:

```bash
 yq e '.spec.groups[] | .rules[] |  "| " + .alert + " | " + (.annotations.summary // "-" | sub("\n",". "))+ " | " + (.annotations.description // "-" | sub("\n",". ")) + " |"' katalog/tigera/on-prem/monitoring/prometheusrules.yaml
```

## EKS Policy-only mode

Follow this documentation:
<https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/eks>

The policy only mode definition YAML was originally taken from EKS documentation, that does not exist anymore:
<https://docs.aws.amazon.com/eks/latest/userguide/calico.html>

The definition file was downloaded from:
<https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/master/calico-crs.yaml>

For more information see:
<https://docs.tigera.io/calico-enterprise/latest/reference/installation/api#operator.tig
