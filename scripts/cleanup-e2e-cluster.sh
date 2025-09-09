#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

echo "🧹 Cleaning up E2E Test Environment"
echo "===================================="

# Function to cleanup specific CNI type
cleanup_cni() {
    local cni_type="$1"
    echo "🔍 Cleaning up ${cni_type} environment..."
    
    # Find environment files for this CNI type
    ENV_PATTERN="env-*-${cni_type}.env"
    ENV_FILES=$(ls ${ENV_PATTERN} 2>/dev/null || echo "")
    
    if [[ -n "$ENV_FILES" ]]; then
        for env_file in $ENV_FILES; do
            echo "📋 Processing environment: $env_file"
            source "$env_file"
            
            # Delete the Kind cluster if it exists
            if [[ -n "$CLUSTER_NAME" ]] && kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
                echo "   🗑️  Deleting cluster: $CLUSTER_NAME"
                kind delete cluster --name "$CLUSTER_NAME"
            else
                echo "   ℹ️  Cluster not found: ${CLUSTER_NAME:-<not set>}"
            fi
            
            # Remove kubeconfig file
            if [[ -n "$KUBECONFIG" && -f "$KUBECONFIG" ]]; then
                echo "   🗑️  Removing kubeconfig: $KUBECONFIG"
                rm -f "$KUBECONFIG"
            fi
            
            # Remove environment file
            echo "   🗑️  Removing environment file: $env_file"
            rm -f "$env_file"
        done
    else
        echo "   ℹ️  No environment files found for ${cni_type}"
    fi
}

# Check command line arguments
if [[ $# -eq 1 ]]; then
    CNI_TYPE="$1"
    if [[ "$CNI_TYPE" != "tigera" && "$CNI_TYPE" != "cilium" ]]; then
        echo "❌ Error: CNI_TYPE must be 'tigera' or 'cilium'"
        echo "Usage: $0 [tigera|cilium]"
        exit 1
    fi
    echo "🎯 Targeted cleanup for: $CNI_TYPE"
    cleanup_cni "$CNI_TYPE"
elif [[ $# -eq 0 ]]; then
    echo "🌍 Full cleanup for all CNI types"
    cleanup_cni "tigera"
    cleanup_cni "cilium"
else
    echo "❌ Error: Invalid number of arguments"
    echo "Usage: $0 [tigera|cilium]"
    echo "   No args: Clean up all CNI types"
    echo "   One arg: Clean up specific CNI type"
    exit 1
fi

# Clean up any remaining temporary files
echo "🧽 Removing temporary files..."
rm -f kind-config-*.yaml
rm -f kubeconfig-e2e-* 

# Show remaining Kind clusters (if any)
echo "🔍 Remaining Kind clusters:"
CLUSTERS=$(kind get clusters 2>/dev/null || echo "")
if [[ -n "$CLUSTERS" ]]; then
    echo "$CLUSTERS" | sed 's/^/   /'
else
    echo "   No Kind clusters found"
fi

echo "✅ Cleanup completed successfully!"