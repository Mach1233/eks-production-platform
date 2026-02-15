# ArgoCD GitOps Configuration

## Overview
ArgoCD watches this Git repository and automatically syncs Kubernetes resources to match the desired state defined in `helm/charts/fintrack/`.

## Directory Structure
```
argocd/
├── bootstrap/
│   └── values.yaml      # ArgoCD Helm install values
├── applications/
│   └── fintrack.yaml    # ArgoCD Application manifest
└── projects/
    └── default.yaml     # ArgoCD AppProject (scoped permissions)
```

## Setup
```bash
# 1. Install ArgoCD
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd \
  -n argocd --create-namespace \
  -f argocd/bootstrap/values.yaml

# 2. Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 3. Apply project and application
kubectl apply -f argocd/projects/default.yaml
kubectl apply -f argocd/applications/fintrack.yaml

# 4. Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open https://localhost:8080
```

## How GitOps Works
1. Developer pushes code → GitHub Actions builds image → pushes to ECR
2. CI updates `helm/charts/fintrack/values.yaml` with new image tag
3. ArgoCD detects Git change → syncs to EKS cluster automatically
4. No manual `kubectl apply` needed — Git is the single source of truth
