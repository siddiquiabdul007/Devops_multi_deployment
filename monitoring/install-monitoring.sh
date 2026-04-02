#!/bin/bash
set -e

echo "Adding Prometheus Helm Repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "Creating monitoring namespace..."
kubectl create namespace monitoring || true

echo "Installing Prometheus and Grafana (kube-prometheus-stack)..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-grafana-values.yaml

echo "Monitoring components installed successfully!"
echo "To access Grafana, run:"
echo "kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"
echo "Default credentials -> User: admin, Password: prom-operator"
