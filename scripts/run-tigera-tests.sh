#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

echo "🧪 Running Tigera E2E Test Suite"
echo "================================"

# Load environment if available
ENV_PATTERN="env-*-tigera.env"
ENV_FILE=$(ls ${ENV_PATTERN} 2>/dev/null | head -1 || echo "")

if [[ -n "$ENV_FILE" && -f "$ENV_FILE" ]]; then
    echo "📋 Loading environment from: $ENV_FILE"
    source "$ENV_FILE"
else
    echo "⚠️  No environment file found (${ENV_PATTERN})"
    echo "   Using default values..."
    export KUBECONFIG="${KUBECONFIG:-$(pwd)/kubeconfig-e2e-tigera}"
    export CNI_TYPE="${CNI_TYPE:-tigera}"
fi

# Validate kubeconfig exists and cluster is accessible
if [[ ! -f "$KUBECONFIG" ]]; then
    echo "❌ Error: Kubeconfig not found at: $KUBECONFIG"
    echo "   Run ./scripts/create-e2e-cluster.sh tigera first"
    exit 1
fi

echo "🔍 Pre-test validation..."
echo "   Kubeconfig: $KUBECONFIG"
echo "   Cluster access:"
if ! kubectl get nodes > /dev/null 2>&1; then
    echo "❌ Error: Cannot access cluster with current kubeconfig"
    echo "   Ensure cluster is running and kubeconfig is correct"
    exit 1
fi
kubectl get nodes

echo "🧪 Step 1: Running Tigera BATS tests..."
if [[ ! -f "./katalog/tests/calico/tigera.sh" ]]; then
    echo "❌ Error: Tigera test file not found at ./katalog/tests/calico/tigera.sh"
    exit 1
fi

echo "   Test file: ./katalog/tests/calico/tigera.sh"
echo "   BATS command: bats -t ./katalog/tests/calico/tigera.sh"
echo ""

# Run the tests with verbose output
bats -t ./katalog/tests/calico/tigera.sh

echo ""
echo "✅ Tigera E2E tests completed successfully!"
echo "🎯 All Tigera functionality verified"