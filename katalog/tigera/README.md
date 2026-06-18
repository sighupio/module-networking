# Tigera Package

The Tigera package provides the Tigera Operator, a Kubernetes Operator for Calico, and some ready to go configurations to enable Networking capabilities for a Kubernetes cluster.

## Tigera Operator

The Tigera Operator handles the installation and life-cycle of the Calico CNI.

### On-premises installation

To install the Tigera operator in an empty on-premises cluster run the following command:

1. Deploy the `on-prem` package, it will deploy both the Operator and the configuration needed to set up Calico CNI:

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f - --server-side
```

If you would like to customize the installation, patch the `tigera/on-prem/custom-resources.yaml` your desired configuration. See the [official documentation](https://projectcalico.docs.tigera.io/getting-started/kubernetes/installation/config-options) for details.

### EKS Policy-only mode installation

The `eks-policy-mode` package is used to run the Tigera Operator for enforcing network policies -and not as CNI- in a EKS cluster.

The policy only mode will install the operator and configure it to not enable the CNI features.

To install it run the following command:

```bash
kustomize build katalog/tigera/policy-only | kubectl apply -f - --server-side
```

> Note that you can also completely replace the AWS CNI with Calico if you need to:
> <https://projectcalico.docs.tigera.io/getting-started/kubernetes/managed-public-cloud/eks>
