#!/bin/bash
# Copyright (c) 2022 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load ./../helper

@test "Nodes in Not Ready state" {
    info
    nodes_not_ready() {
        kubectl get nodes --no-headers | awk  '{print $2}' | uniq | grep -q NotReady
    }
    run nodes_not_ready
    [ "$status" -eq 0 ]
}

@test "Install Prerequisites" {
    info
    install() {
        kubectl apply -f 'https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v3.1.0/katalog/prometheus-operator/crds/0servicemonitorCustomResourceDefinition.yaml'
        kubectl apply -f 'https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v3.1.0/katalog/prometheus-operator/crds/0prometheusruleCustomResourceDefinition.yaml'
    }
    run install
    [ "$status" -eq 0 ]
}

@test "Install Cilium core" {
    info
    show "Creating kube-system namespace..."
    kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -
    show "Deploying Cilium..."
    test() {
        apply katalog/cilium/core
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Cilium Operator Deployment is Ready" {
    info
    show "Waiting for cilium-operator deployment to be fully ready..."
    test() {
        check_deploy_ready "cilium-operator" "kube-system"
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Cilium DaemonSet is Ready" {
    info
    show "Waiting for cilium daemonset to be ready on all nodes..."
    test() {
        check_ds_ready "cilium" "kube-system"
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Nodes in Ready State" {
    info
    show "Verifying all nodes are in Ready state..."
    test() {
        kubectl get nodes --no-headers | awk  '{print $2}' | uniq | grep -q Ready
    }
    run test
    [ "$status" -eq 0 ]
}
