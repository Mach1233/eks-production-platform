# Cloud Native EKS Platform Documentation

Welcome to the comprehensive documentation for the Cloud Native EKS Platform.

## 📚 Documentation Structure

Our documentation is organized by the phase of the project lifecycle:

### [Phase 1: Local Development](development/)
- **[Setup Guide](development/setup.md)**: Prerequisite tools and environment setup.
- **[Workflow Guide](development/workflow.md)**: Running the app locally, testing, and contributing.

### [Phase 2: Infrastructure](infrastructure/)
- **[Architecture](infrastructure/architecture.md)**: High-level infrastructure overview.
- **[Terraform Guide](infrastructure/terraform.md)**: Infrastructure as Code management.
- **[Architecture Decisions (ADRs)](infrastructure/decisions/)**: Key technical decisions.

### [Phase 3: Deployment](deployment/)
- **[GitOps with ArgoCD](deployment/gitops.md)**: Continuous delivery setup.
- **[CI/CD Pipelines](deployment/ci-cd.md)**: GitHub Actions workflows.
- **[Secrets Management](deployment/secrets.md)**: External Secrets Operator usage.

### [Phase 4: Operations & Security](operations/)
- **[Monitoring](operations/monitoring.md)**: Prometheus/Grafana dashboards and alerts.
- **[Security](operations/security.md)**: Policy enforcement, network security, and IAM.
- **[Troubleshooting](operations/troubleshooting.md)**: Common issues and runbooks.

## 🚀 Quick Start

1. **Set up your environment**: follow the [Setup Guide](development/setup.md).
2. **Deploy infrastructure**: follow the [Terraform Guide](infrastructure/terraform.md).
3. **Configure GitOps**: follow the [GitOps Guide](deployment/gitops.md).
4. **Monitor your cluster**: check the [Monitoring Guide](operations/monitoring.md).
