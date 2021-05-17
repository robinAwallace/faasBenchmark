#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install prometheus --namespace monitoring prometheus-community/kube-prometheus-stack

kubectl port-forward -n monitoring prometheus-prometheus-operator-prometheus-0 9090
kubectl port-forward prometheus-grafana-7db74fd7d6-7bvp5 -n monitoring 3000

#clean up
# helm uninstall prometheus --namespace monitoring