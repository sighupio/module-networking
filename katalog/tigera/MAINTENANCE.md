# Tigera Package Maintenance Guide

## Tigera Operator

Tigera operator manifests files are taken as-is from upstream.

Here are the installation notes:
<https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises>

To update the YAML file, run the following command:

```bash
# assuming katalog/tigera is the root of the repository
export CALICO_VERSION="3.30.0"
curl "https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/tigera-operator.yaml" --output operator/tigera-operator.yaml
```

No customizations are made.

## On-prem

For managed on-prem installations, in addition to the operator you need to create a custom resource with the CNI configuration.

Here is the documentation
<https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises>

To download the default configuration from upstream and update the file use the following commands:

```bash
# assuming katalog/tigera is the root of the repository
export CALICO_VERSION="3.30.0"
curl https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/custom-resources.yaml --output on-prem/custom-resources.yaml
```

### Customizations

The on-prem resources file from upstream has been edited with the following:

- Use SIGHUP's registry
- Deleted the `calicoNetwork` section included in the upstream configuration file, the Operator should detect the CIDR from the cluster's installation and set it accordingly.
- Calico ApiServer is not deployed by default by our installation.

### Monitoring

There are some custom headless services and service monitors defined as part of the kustomize project for the on-prem variant.

The dashbaords are the official ones with some minor tuning.

To get the dashboards you can use the following commands:

```bash
# ⚠️ Assuming $PWD == root of the project
export CALICO_VERSION="3.30.0"
# we split the upstream file and store only the json files
curl -L https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/grafana-dashboards.yaml | yq '.data["felix-dashboard.json"]' | sed 's/calico-demo-prometheus/prometheus/g' | jq > ./on-prem/monitoring/dashboards/felix-dashboard.json
curl -L https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/grafana-dashboards.yaml | yq '.data["typha-dashboard.json"]' | sed 's/calico-demo-prometheus/prometheus/g' | jq > ./on-prem/monitoring/dashboards/typa-dashboard.json
```

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

You can generate a markdown table with the rules to include it in the readme with the following commad:

```bash
 yq e '.spec.groups[] | .rules[] |  "| " + .alert + " | " + (.annotations.summary // "-" | sub("\n",". "))+ " | " + (.annotations.description // "-" | sub("\n",". ")) + " |"' katalog/tigera/on-prem/monitoring/prometheusrules.yaml
```

## EKS Policy-only mode

The policy only mode definition YAML is taken from EKS documentation:
<https://docs.aws.amazon.com/eks/latest/userguide/calico.html>

Notice that the manifests are not maintained anymore by AWS.

The definition file has been downloaded from:
<https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/master/calico-crs.yaml>

for more information see:
<https://docs.tigera.io/calico-enterprise/latest/reference/installation/api#operator.tigera.io/v1.CNISpec>
