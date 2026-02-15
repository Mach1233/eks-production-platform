# ArgoCD Setup Guide

## Prerequisites
- EKS cluster running (`kubectl get nodes` works)
- Helm 3 installed
- kubectl configured for the cluster

## Step 1: Install ArgoCD
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd \
  -n argocd --create-namespace \
  -f argocd/bootstrap/values.yaml
```

Wait for pods to be ready:
```bash
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```

## Step 2: Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```
Username: `admin`

## Step 3: Access the UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open [https://localhost:8080](https://localhost:8080) and login.

## Step 4: Apply Project and Application
```bash
kubectl apply -f argocd/projects/default.yaml
kubectl apply -f argocd/applications/fintrack.yaml
```

## Step 5: Verify Sync
In the ArgoCD UI, you should see the `fintrack` application syncing from the Helm chart.

```bash
# CLI check
kubectl get applications -n argocd
```

## GitOps Workflow
```
Code push → GitHub Actions → Build & Push ECR → Update Helm tag in Git → ArgoCD auto-sync → EKS
```

## Troubleshooting
| Issue | Solution |
|-------|----------|
| App stuck "OutOfSync" | Check `argocd app diff fintrack` |
| Sync failed | Check `argocd app logs fintrack` |
| Can't reach ArgoCD UI | Ensure port-forward is active |
