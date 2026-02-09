# Cloud Native EKS Platform

A production-grade cloud-native DevOps project utilizing Terraform, AWS EKS, Next.js, Argo CD, and GitHub Actions.

## Structure
- `terraform/`: Infrastructure as Code modules and environments
- `app/`: Next.js reference application
- `argocd/`: Argo CD configurations (GitOps)
  - `applications/`: Argo CD Application manifests
  - `projects/`: Project definitions
  - `bootstrap/`: Helm values for initial setup
- `.github/workflows/`: CI/CD pipelines

## Branching
- `main`: Production-ready code
- `develop`: Integration branch (staging)
- `feature/*`: Development branches
