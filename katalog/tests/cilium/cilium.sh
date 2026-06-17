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
        kubectl apply -f 'https://raw.githubusercontent.com/sighupio/module-monitoring/v3.1.0/katalog/prometheus-operator/crds/0servicemonitorCustomResourceDefinition.yaml'
        kubectl apply -f 'https://raw.githubusercontent.com/sighupio/module-monitoring/v3.1.0/katalog/prometheus-operator/crds/0prometheusruleCustomResourceDefinition.yaml'
    }
    run install
    [ "$status" -eq 0 ]
}

@test "Install Cilium and cert-manager" {
    info
    show "Deploying Cilium and cert-manager..."
    test() {
        apply katalog/tests/cilium
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

@test "cert-manager-webhook is Ready" {
    info
    show "Waiting for cert-manager-webhook deployments to be fully ready..."
    test() {
        check_deploy_ready "cert-manager-webhook" "cert-manager"
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Hubble is Ready" {
    info
    show "Waiting for Hubble deployments to be fully ready..."
    test() {
        check_deploy_ready "hubble-relay" "kube-system"
        check_deploy_ready "hubble-ui" "kube-system"
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Cilium Health check" {
    info
    show "Running cilium status --wait to check overall health of Cilium components..."
    test() {
        cilium status --wait
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

# TIP: You can uncomment this test so run the Cilium Connectivity test
# NOTE the connectivy tests are time consuming (~10 minutes).
# @test "Cilium Connectivity test" {
#     info
#     show "Running cilium connectivity test..."
#     test() {
#         cilium connectivity test --exit-zero-on-failure
#     }
#     loop_it test 60 5
#     status=${loop_it_result}
#     [ "$status" -eq 0 ]
# }