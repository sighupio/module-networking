#!/bin/bash
# Copyright (c) 2024-present SIGHUP s.r.l All rights reserved.
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

# 
@test "Install Tigera operator and calico operated" {
    info
    show "Creating calico-system namespace..."
    kubectl create namespace calico-system --dry-run=client -o yaml | kubectl apply -f -
    show "Deploying Tigera operator..."
    test() {
        apply katalog/tigera/on-prem
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Tigera Operator Deployment is Ready" {
    info
    show "Waiting for tigera-operator deployment to be fully ready..."
    test() {
        check_deploy_ready "tigera-operator" "tigera-operator"
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Calico Node DaemonSet is Ready" {
    info
    show "Waiting for calico-node daemonset to be ready on all nodes..."
    test() {
        check_ds_ready "calico-node" "calico-system"
    }
    loop_it test 120 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Calico Kube Controllers Deployment is Ready" {
    info  
    show "Waiting for calico-kube-controllers deployment to be fully ready..."
    test() {
        check_deploy_ready "calico-kube-controllers" "calico-system"
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Calico Typha Deployment is Ready (if exists)" {
    info
    show "Checking if calico-typha deployment exists and is ready..."
    test() {
        # First check if typha exists, if not, that's fine for small clusters
        if kubectl get deployment calico-typha -n calico-system &>/dev/null; then
            check_deploy_ready "calico-typha" "calico-system"
        else
            show "Calico Typha not deployed (expected for small clusters)"
            return 0
        fi
    }
    loop_it test 60 5
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Nodes in ready State" {
    info
    test() {
        kubectl get nodes --no-headers | awk  '{print $2}' | uniq | grep -q Ready
    }
    run test
    [ "$status" -eq 0 ]
}

@test "Apply whitelist-system-ns GlobalNetworkPolicy" {
    info
    install() {
        kubectl apply -f examples/globalnetworkpolicies/1.whitelist-system-namespace.yml
    }
    run install
    [ "$status" -eq 0 ]
}

@test "Create a non-whitelisted namespace with an app" {
    info
    install() {
        kubectl create ns test-1
        kubectl apply -f katalog/tests/calico/resources/echo-server.yaml -n test-1
        kubectl wait -n test-1 --for=condition=ready --timeout=120s pod -l app=echoserver
    }
    run install
    [ "$status" -eq 0 ]
}

@test "Test app within the same namespace" {
    info
    test() {
        kubectl create job -n test-1 isolated-test --image travelping/nettools -- curl http://echoserver.test-1.svc.cluster.local
        kubectl wait -n test-1 --for=condition=complete --timeout=30s job/isolated-test
    }
    run test
    [ "$status" -eq 0 ]
}

@test "Test app from a system namespace" {
    info
    test() {
        kubectl create job -n kube-system isolated-test --image travelping/nettools -- curl http://echoserver.test-1.svc.cluster.local
        kubectl wait -n kube-system --for=condition=complete --timeout=30s job/isolated-test
    }
    run test
    [ "$status" -eq 0 ]
}

@test "Test app from a different namespace" {
    info
    test() {
        kubectl create ns test-1-1
        kubectl create job -n test-1-1 isolated-test --image travelping/nettools -- curl http://echoserver.test-1.svc.cluster.local
        kubectl wait -n test-1-1 --for=condition=complete --timeout=30s job/isolated-test
    }
    run test
    [ "$status" -eq 0 ]
}

@test "Apply deny-all GlobalNetworkPolicy" {
    info
    install() {
        kubectl apply -f examples/globalnetworkpolicies/2000.deny-all.yml
    }
    run install
    [ "$status" -eq 0 ]
}

@test "Test app from the same namespace (isolated namespace)" {
    info
    test() {
        kubectl create job -n test-1 isolated-test-1 --image travelping/nettools -- curl http://echoserver.test-1.svc.cluster.local
        kubectl wait -n test-1 --for=condition=complete --timeout=30s job/isolated-test-1
    }
    run test
    [ "$status" -eq 1 ]
}

@test "Test app from a system namespace (isolated namespace)" {
    info
    test() {
        kubectl create job -n kube-system isolated-test-1 --image travelping/nettools -- curl http://echoserver.test-1.svc.cluster.local
        kubectl wait -n kube-system --for=condition=complete --timeout=30s job/isolated-test-1
    }
    run test
    [ "$status" -eq 0 ]
}

@test "Test app from a different namespace (isolated namespace)" {
    info
    test() {
        kubectl create job -n test-1-1 isolated-test-1 --image travelping/nettools -- curl http://echoserver.test-1.svc.cluster.local
        kubectl wait -n test-1-1 --for=condition=complete --timeout=30s job/isolated-test-1
    }
    run test
    [ "$status" -eq 1 ]
}
