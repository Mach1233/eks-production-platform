# Monitoring Setup Guide

## Overview
FinTrack uses Prometheus + Grafana for metrics and Fluent Bit for log shipping to CloudWatch.

## Prerequisites
- EKS cluster running
- IRSA role for Fluent Bit (from Terraform output: `fluent_bit_role_arn`)
- Helm 3 installed

## Step 1: Install Prometheus + Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f k8s/monitoring/prometheus-values.yaml
```

## Step 2: Apply Alert Rules
```bash
kubectl apply -f k8s/monitoring/alerts.yaml
```

## Step 3: Access Grafana
```bash
kubectl port-forward svc/prometheus-grafana -n monitoring 3001:80
```
Open [http://localhost:3001](http://localhost:3001)
- Username: `admin`
- Password: `admin` (change in production)

## Step 4: Install Fluent Bit
```bash
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Update IRSA role ARN in values first
helm install fluent-bit fluent/fluent-bit \
  -n logging --create-namespace \
  -f k8s/monitoring/fluent-bit-values.yaml
```

## Step 5: Verify
```bash
# Check Prometheus targets
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
# Open http://localhost:9090/targets

# Check Fluent Bit logs
kubectl logs -n logging -l app.kubernetes.io/name=fluent-bit --tail=20

# Check CloudWatch
aws logs describe-log-groups --log-group-name-prefix /fintrack
```

## Alerts Configured
| Alert | Condition | Severity |
|-------|-----------|----------|
| HighCPUUsage | >80% CPU for 5min | Warning |
| PodCrashLooping | Restarts in 15min | Critical |
| PodNotReady | Not ready for 5min | Warning |
| HighMemoryUsage | >80% memory for 5min | Warning |
