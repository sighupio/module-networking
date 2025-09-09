#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

# Script to create Kind cluster for E2E testing with CNI disabled
# Usage: ./create-e2e-cluster.sh <CNI_TYPE> [KUBE_VERSION]
# Examples:
#   ./create-e2e-cluster.sh tigera 1.33.0
#   ./create-e2e-cluster.sh cilium 1.32.2

CNI_TYPE="${1:-tigera}"
KUBE_VERSION="${2:-1.33.0}"

# Validate CNI type
if [[ "$CNI_TYPE" != "tigera" && "$CNI_TYPE" != "cilium" ]]; then
    echo "❌ Error: CNI_TYPE must be 'tigera' or 'cilium'"
    echo "Usage: $0 <CNI_TYPE> [KUBE_VERSION]"
    exit 1
fi

# Validate Kubernetes version format
if ! echo "$KUBE_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "❌ Error: KUBE_VERSION must be in format X.Y.Z (e.g., 1.33.0)"
    echo "Usage: $0 <CNI_TYPE> [KUBE_VERSION]"
    exit 1
fi

echo "🚀 Creating E2E Test Cluster for Module Networking ($CNI_TYPE)"
echo "============================================================"

# Configuration
export DRONE_BUILD_NUMBER="${DRONE_BUILD_NUMBER:-9999}"
export DRONE_REPO_NAME="${DRONE_REPO_NAME:-module-networking}"
CLUSTER_NAME="${DRONE_REPO_NAME}-${DRONE_BUILD_NUMBER}-${KUBE_VERSION//./}-${CNI_TYPE}"
KUBECONFIG_PATH="$(pwd)/kubeconfig-e2e-${CNI_TYPE}"

echo "📋 Configuration:"
echo "   CNI Type: ${CNI_TYPE}"
echo "   Kubernetes Version: ${KUBE_VERSION}"
echo "   Cluster Name: ${CLUSTER_NAME}"
echo "   Kubeconfig: ${KUBECONFIG_PATH}"

# Check if cluster already exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "⚠️  Cluster '${CLUSTER_NAME}' already exists. Deleting first..."
    kind delete cluster --name "${CLUSTER_NAME}"
fi

echo "📦 Step 1: Creating Kind cluster with CNI disabled..."

# Use static multi-node Kind config for realistic CNI testing
KIND_CONFIG="katalog/tests/kind/config.yml"

echo "   Using Kind node image: registry.sighup.io/fury/kindest/node:v${KUBE_VERSION}"
echo "   Using multi-node config: ${KIND_CONFIG}"
kind create cluster --name "${CLUSTER_NAME}" --image "registry.sighup.io/fury/kindest/node:v${KUBE_VERSION}" --config "${KIND_CONFIG}"

echo "📋 Step 2: Setting up kubeconfig..."
kind get kubeconfig --name "${CLUSTER_NAME}" > "${KUBECONFIG_PATH}"
export KUBECONFIG="${KUBECONFIG_PATH}"

echo "⏳ Step 3: Waiting for cluster to be ready..."
until kubectl get serviceaccount default > /dev/null 2>&1; do 
  echo "   Waiting for control-plane..." 
  sleep 2
done

echo "🔍 Step 4: Cluster validation..."
echo "   Nodes:"
kubectl get nodes -o wide
echo "   System pods (should show no CNI pods):"
kubectl get pods -A --field-selector=status.phase!=Succeeded | grep -E "(kube-system|kube-proxy)" || echo "   No system pods found (expected)"

# Save environment details for test scripts
ENV_FILE="env-${CLUSTER_NAME}.env"
cat > "${ENV_FILE}" <<EOF
export CLUSTER_NAME="${CLUSTER_NAME}"
export KUBECONFIG="${KUBECONFIG_PATH}"
export CNI_TYPE="${CNI_TYPE}"
export KUBE_VERSION="${KUBE_VERSION}"
export KIND_CONFIG="${KIND_CONFIG}"
EOF

echo "✅ E2E cluster created successfully!"
echo "   Environment file: ${ENV_FILE}"
echo "   Ready for ${CNI_TYPE} E2E testing"

# No cleanup needed - using static config file