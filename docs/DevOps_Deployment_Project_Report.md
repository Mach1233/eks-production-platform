# Cloud-Native DevOps Deployment Project Report

**Project Title:** FinTrack Platform - End-to-End DevOps Deployment on AWS EKS  
**Author:** Mohamed Mechraoui  
**Technology Stack:** AWS (VPC, EKS, IAM, ECR, ALB), Terraform, Kubernetes, Helm, Docker, GitHub Actions, Argo CD, MongoDB Atlas, Prometheus/Grafana, Fluent Bit, Kyverno  
**Date:** February 15, 2026  

---

## Short Project Description
This report documents a full DevOps implementation for deploying a production-style web platform on AWS. The solution uses Terraform for Infrastructure as Code, EKS for orchestration, Docker for packaging, GitHub Actions for CI, Argo CD for GitOps-based CD, and MongoDB Atlas as an external managed database. The architecture is designed around private workloads, controlled internet exposure, least-privilege IAM, and repeatable automated delivery.

---

## Table of Contents
1. Cover Page  
2. Executive Summary  
3. Global Architecture Overview  
4. Infrastructure as Code (Terraform)  
5. Docker Configuration  
6. Kubernetes Configuration  
7. Networking Deep Explanation  
8. CI/CD Pipeline (GitHub Actions + GitOps)  
9. Security Architecture  
10. Monitoring and Scaling  
11. Deployment Process (Step-by-Step)  
12. Challenges Faced and Solutions  
13. Best Practices Applied  
14. Future Improvements  
15. Conclusion  
16. Appendix A - DevOps File-by-File Index  
17. Appendix B - Operational Command Reference  

---

## 2. Executive Summary
This project achieves a complete cloud-native deployment pipeline from infrastructure provisioning to automated production rollout. The main objective is to demonstrate professional DevOps engineering practices in a realistic, portfolio-grade environment:

- Infrastructure is provisioned using modular Terraform.
- Application runtime is containerized with Docker.
- Workloads run on AWS EKS in private subnets.
- Public traffic is managed through Kubernetes Ingress and AWS load balancing.
- Secrets are handled without hardcoding credentials in source control.
- CI/CD is automated with image build, security scan, registry push, and GitOps deployment.
- Monitoring and policy controls are included for operational readiness.

### Why DevOps Matters in This Project
DevOps is not only automation. In this implementation, it provides:

- Repeatability: identical environments can be recreated reliably.
- Traceability: every deployment change is tied to Git history.
- Security by design: IAM roles, secret externalization, and network controls are embedded.
- Operational confidence: scaling, health probes, observability, and policy enforcement reduce runtime risk.

### High-Level Outcome
The final platform is a production-oriented deployment architecture for a web workload where infrastructure, deployment, and operations are treated as code and managed through version-controlled workflows.

---

## 3. Global Architecture Overview

### 3.1 High-Level Architecture Narrative
The platform is deployed in AWS `eu-north-1` using a dedicated VPC (`10.0.0.0/16`). Public subnets host internet-facing network edges and NAT egress components. Private subnets host the EKS worker node workloads. External users access the application through an ingress path backed by AWS load balancing, while pods connect outward to MongoDB Atlas using controlled egress through a NAT instance with static public IP.

The software delivery model follows GitOps principles:

1. Developer pushes changes.
2. GitHub Actions builds/scans/pushes container images to ECR.
3. Pipeline updates Helm values (image tag).
4. Argo CD detects repository change and synchronizes cluster state.

### 3.2 Logical Architecture Diagram (ASCII)
```text
                           +---------------------------+
                           |      End User Browser     |
                           +-------------+-------------+
                                         |
                                         | HTTP/HTTPS
                                         v
                    +--------------------------------------------+
                    |            AWS Load Balancer               |
                    | (Managed by K8s Ingress + ALB Controller) |
                    +--------------------+-----------------------+
                                         |
                                         v
+----------------------------------------------------------------------------------+
| AWS Account / Region: eu-north-1                                                 |
|                                                                                  |
|  VPC: 10.0.0.0/16                                                                |
|                                                                                  |
|  Public Subnets                                  Private Subnets                  |
|  -------------------------                       -----------------------------     |
|  - Internet Gateway (IGW)                        - EKS Worker Nodes              |
|  - NAT Instance (t4g.micro + EIP)                - FinTrack Pods                 |
|                                                  - Argo CD                        |
|                                                  - External Secrets Operator      |
|                                                  - Monitoring stack               |
|                                                                                  |
+----------------------------------------------------------------------------------+
                                         |
                                         | Outbound via NAT EIP
                                         v
                           +-----------------------------+
                           |        MongoDB Atlas        |
                           |      (External Service)     |
                           +-----------------------------+

CI/CD + GitOps Plane:
Developer -> GitHub -> GitHub Actions -> AWS ECR -> Git update (Helm tag)
       -> Argo CD sync -> Kubernetes deployment
```

### 3.3 Main Architecture Components
- **VPC and subnet segmentation**: isolates external entry and internal compute.
- **EKS cluster**: orchestrates application containers.
- **Managed node group**: worker capacity with autoscaling boundaries.
- **Ingress + AWS LB integration**: controlled public access path.
- **ECR registry**: internal image distribution source.
- **MongoDB Atlas**: managed external database connectivity.
- **Argo CD**: declarative delivery and drift correction.
- **Prometheus/Grafana + Fluent Bit**: metrics and logs.
- **Kyverno**: policy guardrails at admission time.

### 3.4 Deployment Topology
- **Public plane**: ALB ingress path, NAT instance, IGW.
- **Private plane**: application runtime and operational controllers.
- **Control plane**: GitHub Actions + Argo CD synchronization.
- **Data plane**: Pod-to-database traffic through controlled egress.

---

## 4. Infrastructure as Code (Terraform)

Terraform is structured into reusable modules and an environment composition layer.

### 4.1 Terraform Structure in This Project
- Root provider/version pinning: `terraform/versions.tf`
- Environment composition: `terraform/environments/staging/*`
- Reusable modules:
  - `terraform/modules/vpc/*`
  - `terraform/modules/eks/*`
  - `terraform/modules/ecr/*`
  - `terraform/modules/iam/*`
  - `terraform/modules/rds/*` (optional and disabled)

### 4.2 `main.tf` (Environment Composition)
File: `terraform/environments/staging/main.tf`

This file orchestrates module calls and defines the final staging stack:

- Sets region `eu-north-1` and common tags.
- Calls VPC module with public/private subnets across 3 AZs.
- Calls EKS module with private subnet scheduling and spot node settings.
- Calls ECR module for image storage and retention policy.
- Calls IAM module for IRSA roles (ESO, Fluent Bit, ALB controller).
- References RDS module but keeps it disabled (`enabled = false`) because Atlas is the active DB strategy.

### 4.3 `provider.tf` Equivalent
There is no dedicated `provider.tf` file in this repository. Provider configuration is in:
- `terraform/environments/staging/main.tf` (AWS provider region)
- `terraform/versions.tf` (required providers + version constraints)

This is a valid Terraform layout where provider and required provider constraints are split logically.

### 4.4 `variables.tf`
Files:
- `terraform/environments/staging/variables.tf`
- Per-module variables under `terraform/modules/*/variables.tf`

Purpose:
- Define environment-level variables (region, environment).
- Define module input contracts (CIDRs, node sizes, repository name, OIDC values, etc.).

Professional benefit:
- Improves reusability, readability, and environment portability.

### 4.5 `outputs.tf`
Files:
- `terraform/environments/staging/outputs.tf`
- Module-level outputs under `terraform/modules/*/outputs.tf`

Important exported values:
- VPC ID and NAT EIP.
- Cluster name and endpoint.
- ECR repository URL.
- IRSA role ARNs.

Outputs are operationally critical for wiring post-provisioning steps (kubectl config, Helm values, IAM annotations, Atlas IP allowlist).

### 4.6 `vpc.tf` Equivalent: `terraform/modules/vpc/main.tf`
This module creates network primitives:

- `aws_vpc`
- `aws_internet_gateway`
- Public subnets with ELB tag
- Private subnets with internal-ELB tag
- Public and private route tables + associations
- NAT instance (not NAT Gateway) with:
  - ARM AMI lookup
  - `source_dest_check = false`
  - iptables masquerading via `user_data`
  - static EIP (used for Atlas allowlisting)

### 4.7 `eks.tf` Equivalent: `terraform/modules/eks/main.tf`
Uses `terraform-aws-modules/eks/aws` module:

- EKS control plane with public and private endpoint access.
- IRSA enabled.
- Managed node group with SPOT capacity.
- Add-ons: CoreDNS, kube-proxy, VPC CNI.
- Tags propagated for governance.

### 4.8 `iam.tf` Equivalent: `terraform/modules/iam/main.tf`
Defines IRSA roles and policies:

- **ESO role**: read only from `fintrack/*` secrets path in Secrets Manager.
- **Fluent Bit role**: write logs to `/fintrack/*` CloudWatch log groups.
- **ALB controller role**: attached ELB full-access managed policy.

Each trust policy is constrained by OIDC audience and Kubernetes service account subject.

### 4.9 Security Groups and Route Tables
- Explicit NAT SG in VPC module:
  - Ingress: from private subnet CIDRs.
  - Egress: full outbound.
- EKS and node SGs are generated by EKS module and exposed as outputs.
- Route tables:
  - Public route table to IGW.
  - Private route table default route to NAT instance interface.

### 4.10 NAT Gateway vs NAT Instance
The project intentionally uses NAT instance for cost control.

- Pros: significantly lower cost in learning/staging context.
- Trade-off: less managed/high-availability than NAT Gateway.

### 4.11 Internet Gateway
Created in VPC module and attached to VPC. It is the internet edge for public subnet resources and egress path anchor for NAT.

### 4.12 How Terraform Works in This Pipeline
Operational flow:

```bash
cd terraform/environments/staging
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

- `init`: downloads providers and prepares backend.
- `plan`: computes infrastructure diff.
- `apply`: enacts desired state.

### 4.13 State Management
Current backend: local (`backend "local"` in `terraform/environments/staging/backend.tf`).

> **Mentor Note / Improvement:** Moving to S3 backend + DynamoDB locking is highly recommended for team-based state safety.


Professional production recommendation:
- Move to remote backend (S3 + DynamoDB lock table).
- Enable encryption at rest, versioning, and least-privilege IAM for state operations.

### 4.14 Terraform Module Dependency Flow
```text
VPC -> EKS -> IAM
  \       \-> outputs for cluster/OIDC used by IAM
   \-> RDS(optional, disabled)
ECR is independent but consumed by CI/CD and Helm image configuration.
```

---

## 5. Docker Configuration

### 5.1 Dockerfile Location and Purpose
File: `app/Dockerfile`

This Dockerfile packages the runtime workload as an immutable container image, optimized for Kubernetes deployment.

### 5.2 Multi-Stage Build Design
Stages used:
- `base`: node runtime base image (`node:18-alpine`)
- `deps`: installs dependencies
- `builder`: compiles production artifacts
- `runner`: minimal runtime with non-root user

Benefits:
- Smaller final image.
- Cleaner dependency boundary.
- Reduced attack surface.

### 5.3 Image Optimization Choices
- Alpine base image reduces footprint.
- Build artifacts are copied selectively into runtime stage.
- Runtime executes as non-root user (`nextjs`, UID 1001).
- Exposes only necessary port (`3000`).

### 5.4 `.dockerignore` Status
No `.dockerignore` file exists at repository root or in `app/` currently.

Impact:
- Docker build context may include unnecessary files.
- Build times and image build I/O may be larger than required.

Recommendation:
- Added `.dockerignore` to exclude local caches (`node_modules`), docs, and VCS metadata from build context.


### 5.5 Build and Push Process in CI
Implemented in `.github/workflows/deploy.yaml`:

1. Build image in CI.
2. Scan image with Trivy.
3. Authenticate to AWS with OIDC role.
4. Push tagged image to ECR.
5. Update Helm `values.yaml` with new image tag and repo URL.

This aligns with immutable artifact promotion and GitOps handoff.

---

## 6. Kubernetes Configuration

The repository uses a Helm chart (`helm/charts/fintrack`) as the canonical Kubernetes packaging format.

### 6.1 Important Clarification for Requested Files
You asked for explanations of `namespace.yaml`, `deployment.yaml`, `service.yaml`, `ingress.yaml`, `configmap.yaml`, `secret.yaml`, and HPA.

In this implementation:
- `deployment.yaml`, `service.yaml`, `ingress.yaml`, `hpa.yaml` exist as Helm templates.
- `namespace.yaml` does not exist as standalone file; namespace is created by Argo CD sync option `CreateNamespace=true` and project destination constraints.
- `configmap.yaml` does not exist in chart; non-sensitive runtime values are currently in `values.yaml` and templated env vars.
- `secret.yaml` does not exist in static form by design; secrets are generated dynamically via `externalsecret.yaml` (External Secrets Operator).

### 6.2 `deployment.yaml`
File: `helm/charts/fintrack/templates/deployment.yaml`

Key fields explained:
- `apiVersion: apps/v1`, `kind: Deployment`: declarative rollout object.
- `metadata.labels`: standardized app labels from helper template.
- `spec.replicas`: only set when HPA is disabled.
- `selector.matchLabels`: binds deployment to matching pod labels; immutable identity anchor.
- `template.metadata.labels`: pod identity labels for selection and policy targeting.
- `serviceAccountName`: binds pod to IRSA-compatible K8s service account.
- `containers[].image`: image repository and tag sourced from Helm values.
- `ports.containerPort`: internal app listening port.
- `env` + `envFrom.secretRef`: injects static env and externalized secrets.
- `resources.requests/limits`: schedules and constrains CPU/memory use.
- `livenessProbe/readinessProbe`: health-driven restart and traffic gating.

### 6.3 `service.yaml`
File: `helm/charts/fintrack/templates/service.yaml`

Key fields:
- `kind: Service`, `type: ClusterIP`: internal stable endpoint.
- `ports.port`: service port exposed internally.
- `ports.targetPort`: container port receiving traffic.
- `selector`: matches pods by labels.

Role:
- Decouples pod IP changes from internal service routing.

### 6.4 `ingress.yaml`
File: `helm/charts/fintrack/templates/ingress.yaml`

Key fields:
- `ingressClassName: alb`: integrates with AWS load balancer controller.
- ALB annotations define scheme, target type, listener config, health path.
- `rules[].host` + `paths[]`: HTTP routing rules to backend service.

Role:
- Externalizes service using managed AWS load balancing.

### 6.5 `hpa.yaml`
File: `helm/charts/fintrack/templates/hpa.yaml`

Key fields:
- `kind: HorizontalPodAutoscaler` (autoscaling/v2).
- `scaleTargetRef`: target deployment to scale.
- `minReplicas`, `maxReplicas`: scaling bounds.
- CPU utilization metric target (`averageUtilization`).

Role:
- Automatically adjusts replica count based on load.

### 6.6 `externalsecret.yaml` (Secret Management Equivalent)
File: `helm/charts/fintrack/templates/externalsecret.yaml`

Key fields:
- `secretStoreRef`: references cluster secret provider integration.
- `target.name`: name of generated Kubernetes Secret.
- `data[]`: mapping between K8s secret keys and remote secret paths.

Role:
- Replaces static `Secret` manifests and keeps credentials out of Git.

### 6.7 `networkpolicy.yaml`
File: `helm/charts/fintrack/templates/networkpolicy.yaml`

Policy behavior:
- Defines ingress/egress controls for selected app pods.
- Allows ingress on app port.
- Allows egress for DNS (53), HTTPS (443), and MongoDB port (27017).

Role:
- Enforces controlled pod communication and egress restrictions.

### 6.8 `serviceaccount.yaml`
File: `helm/charts/fintrack/templates/serviceaccount.yaml`

Role:
- Binds runtime identity to pods.
- Supports IAM role annotation for IRSA-based AWS access.

### 6.9 Internal Service Communication Model
```text
Ingress (ALB) -> Service (ClusterIP:80) -> Pods (targetPort:3000)
Pods -> DNS/HTTPS/MongoDB egress (as allowed by NetworkPolicy)
Pods <- Secret materialized by ESO into Kubernetes Secret
```

### 6.10 Helm Values Control Plane
File: `helm/charts/fintrack/values.yaml`

This values file centralizes deployment behavior:
- image repo/tag
- replica count
- service and ingress settings
- HPA settings
- resources
- external secret mapping
- service account and network policy toggles

It acts as the GitOps deployment parameter source updated by CI.

---

## 7. Networking Deep Explanation

### 7.1 VPC CIDR and Subnets
- VPC CIDR: `10.0.0.0/16`
- Public subnets:
  - `10.0.101.0/24`
  - `10.0.102.0/24`
  - `10.0.103.0/24`
- Private subnets:
  - `10.0.1.0/24`
  - `10.0.2.0/24`
  - `10.0.3.0/24`

Distribution across three AZs improves resilience.

### 7.2 Public vs Private Routing
- Public route table has default route to IGW.
- Private route table has default route to NAT instance network interface.

Result:
- Private workloads are not directly internet-addressable.
- Outbound internet for private workloads remains possible.

### 7.3 Security Groups
- Explicit NAT SG allows ingress from private CIDRs and egress to internet.
- EKS cluster/node SGs are managed by EKS module.

Security effect:
- Traffic control exists both at subnet routing and security group levels.

### 7.4 NACL Design
No custom NACL resources are declared in Terraform modules.

Interpretation:
- Default VPC NACL behavior applies unless manually altered outside Terraform.

Engineering recommendation:
- For strict compliance environments, define explicit NACLs as code for deterministic behavior.

### 7.5 Private Node Connectivity to MongoDB Atlas
Path:
1. Pod in private subnet initiates outbound DB connection (TCP 27017).
2. Traffic reaches private route table default route.
3. Route forwards through NAT instance.
4. NAT EIP appears as source IP on internet.
5. Atlas allows connection if NAT EIP is in Atlas allowlist.

Critical operational dependency:
- NAT EIP output from Terraform must remain synchronized with Atlas IP access list.

### 7.6 NAT Gateway Role (Conceptual) vs Actual Implementation
Requested topic includes NAT Gateway. In this project, NAT Gateway is not provisioned. NAT responsibilities are fulfilled by an EC2 NAT instance for cost optimization.

### 7.7 Load Balancer Role
Load balancing is integrated through Kubernetes Ingress annotations + AWS LB controller:

- External traffic termination and forwarding.
- Health-check driven backend targeting.
- Decoupling user access from pod lifecycle.

### 7.8 End-to-End Traffic Flow
```text
User -> ALB/Ingress -> Service -> Pod
Pod -> NAT -> Internet -> MongoDB Atlas
Pod logs -> Fluent Bit -> CloudWatch
Metrics -> Prometheus -> Grafana dashboards
```

---

## 8. CI/CD Pipeline (GitHub Actions)

### 8.1 Workflow Inventory
- `deploy.yaml` (primary deployment pipeline)

The production-relevant flow currently centers on `deploy.yaml`.

### 8.2 `deploy.yaml` Trigger and Scope
Triggers:
- Push to `develop` branch.
- Path filters on `app/**`, `helm/**`, and workflow file.
- Manual `workflow_dispatch`.

This supports controlled deployment branch strategy for staging-like operations.

### 8.3 Job Breakdown

#### Job 1: Build
- Checks out source.
- Generates short image tag from commit SHA.
- Uses Buildx for efficient builds and cache reuse.
- Builds image locally in CI context.

#### Job 2: Security Scan
- Builds scan image.
- Runs Trivy.
- Fails pipeline on High/Critical vulnerabilities.

#### Job 3: Push to ECR
- Authenticates to AWS via OIDC role assumption.
- Logs into ECR.
- Builds tagged image and pushes to ECR registry.

#### Job 4: Update Helm Values
- Fetches ECR registry URL.
- Updates Helm `values.yaml` image repository and tag.
- Commits and pushes change to Git.

### 8.4 Secrets Management in CI
Used secrets:
- `AWS_ROLE_ARN` (OIDC assume-role target)
- `GITHUB_TOKEN` (repo write for values update commit)

Security model:
- Avoids long-lived static AWS keys in repository secrets.
- Uses federated identity (OIDC) with short-lived credentials.

### 8.5 Environment Variables in Workflow
Key env vars:
- `AWS_REGION`
- `ECR_REPOSITORY`
- `HELM_VALUES_PATH`

They standardize job behavior and reduce duplication.

### 8.6 Branch Strategy (Observed)
Current workflow behavior indicates:
- `develop`: active deployment automation path.
- `main`: basic CI hooks and placeholders.

Recommendation:
- Formalize branch environment mapping (e.g., `develop -> staging`, `main -> production`).
- Enforce protection and review policy per environment branch.

### 8.7 GitOps Integration
After image push, CI updates chart values in Git. Argo CD auto-sync then applies new desired state. This removes manual `kubectl apply` from release flow and improves auditability.

### 8.8 CI/CD Sequence Diagram (ASCII)
```text
Developer Push (develop)
        |
        v
GitHub Actions: build -> scan -> push ECR -> update Helm values in Git
        |
        v
Argo CD detects new commit
        |
        v
Argo CD syncs Helm chart to EKS namespace
        |
        v
Kubernetes performs rolling update to new image tag
```

---

## 9. Security Architecture

Security is implemented as layered controls across identity, secret handling, network boundaries, image hygiene, and policy enforcement.

### 9.1 IAM Roles and Least Privilege
Via IRSA module (`terraform/modules/iam/main.tf`):
- ESO role: read-only narrow scope on secrets path.
- Fluent Bit role: limited CloudWatch logs write permissions.
- ALB controller role: load balancer management permissions.
- **Fluent Bit role**: Correctly annotated in `fluent-bit-values.yaml` to use IRSA.

Trust boundary:
- OIDC subject conditions bind IAM role assumption to exact Kubernetes service accounts.

### 9.2 Secrets Management
- No static secret manifests in Git.
- AWS Secrets Manager stores sensitive values.
- External Secrets Operator synchronizes values into runtime K8s Secret objects.

Operational effect:
- Improves secret rotation and reduces repository exposure risk.

### 9.3 Private Subnet Workload Isolation
- Worker nodes and app pods operate in private subnets.
- Inbound internet path is restricted to ingress/lb plane.
- Outbound internet is controlled through NAT route.

### 9.4 TLS / HTTPS Considerations
Current ingress annotations configure HTTP listener (`80`) in `values.yaml`.

Production hardening recommendation (Implemented in code comments):
- Add TLS listener (`443`) and ACM certificates.
- Enforce HTTP->HTTPS redirection.
- Tighten ingress annotation set for TLS-only front door.


### 9.5 Secure Database Access
- Database is external (MongoDB Atlas).
- Access controlled by Atlas IP allowlist (NAT EIP).
- Secret URI injection handled through ESO path `fintrack/mongodb-uri`.

### 9.6 Policy Enforcement with Kyverno
Files:
- `k8s/kyverno/policies/disallow-privileged.yaml`
- `k8s/kyverno/policies/require-labels.yaml`

Enforced controls:
- Blocks privileged containers.
- Requires standardized deployment labels.
- **Pod Security**: `securityContext` enforced (non-root, read-only FS).

### 9.7 Supply Chain Security Controls
- Trivy scan in CI gates deployment pipeline.
- ECR image scanning enabled on push.

Combined effect:
- Vulnerability detection at both pipeline and registry layers.

---

## 10. Monitoring and Scaling

### 10.1 Horizontal Scaling
- App-level HPA enabled:
  - min 2 replicas
  - max 5 replicas
  - CPU target 70%

### 10.2 Node-Level Scaling Envelope
EKS managed node group settings define capacity boundaries:
- min: 1
- desired: 2
- max: 3

This controls worker footprint while allowing elasticity.

### 10.3 Load Balancing
- Ingress + AWS LB controller provides external traffic distribution.
- Service object provides internal traffic fan-in to pods.

### 10.4 Pod Resource Governance
Values file defines requests/limits:
- requests: `100m` CPU, `128Mi` memory
- limits: `250m` CPU, `256Mi` memory

Benefits:
- Predictable scheduling.
- Reduced noisy-neighbor behavior.
- Cleaner autoscaling signals.

### 10.5 Metrics Stack
Files:
- `k8s/monitoring/prometheus-values.yaml`
- `k8s/monitoring/alerts.yaml`

Features:
- Prometheus scraping and retention policy.
- Grafana dashboarding.
- Alert rules for CPU, memory, readiness, and restart behavior.

### 10.6 Logging Stack
File:
- `k8s/monitoring/fluent-bit-values.yaml`

Features:
- DaemonSet log collection from container logs.
- Enrichment with Kubernetes metadata.
- CloudWatch output via IRSA permissions.

### 10.7 Operations Readiness Summary
The project includes baseline production observability elements:
- Metrics
- Alerts
- Logs
- Autoscaling
- Resource controls

---

## 11. Deployment Process (Step-by-Step)

This section tracks the complete lifecycle from code change to production workload state.

### 11.1 Infrastructure Provisioning Stage
1. Operator runs Terraform from `terraform/environments/staging`.
2. Terraform creates or updates VPC, subnets, IGW, NAT, route tables.
3. Terraform provisions EKS control plane and node group.
4. Terraform creates ECR repository and lifecycle policy.
5. Terraform creates IRSA IAM roles and exports outputs.
6. Operator configures kubectl context for the cluster.

### 11.2 Platform Services Stage
7. Argo CD is installed and configured (`argocd/bootstrap/values.yaml`).
8. Argo CD project and application are applied (`argocd/projects/default.yaml`, `argocd/applications/fintrack.yaml`).
9. Monitoring stack and policies are installed as required.

### 11.3 Application Delivery Stage
10. Developer pushes code to `develop`.
11. GitHub Actions pipeline starts (`deploy.yaml`).
12. Build job produces container image artifact.
13. Scan job validates vulnerability thresholds.
14. Push job uploads image to ECR with commit-based tag.
15. Update job writes new image values into Helm values file and commits.
16. Argo CD auto-detects Git change and syncs namespace resources.
17. Kubernetes performs rolling update of deployment.
18. Service and ingress route user traffic to healthy pods.

### 11.4 Runtime Validation Stage
19. Readiness/liveness probes validate pod availability.
20. HPA monitors CPU and scales replicas if needed.
21. Prometheus, Grafana, and Fluent Bit provide telemetry.

### 11.5 Continuous Operation
22. Subsequent commits repeat the same immutable release loop.
23. Drift or manual changes are corrected by Argo CD self-heal.

---

## 12. Challenges Faced and Solutions

This section captures typical and repository-aligned challenges in this architecture and the implemented or recommended resolutions.

### 12.1 Networking Cost vs Reliability
**Challenge:** NAT Gateway cost is high for budget-constrained staging portfolio environments.  
**Solution:** Replace with ARM NAT instance (`t4g.micro`) and static EIP.  
**Trade-off:** Accept reduced managed HA in exchange for major cost reduction.

### 12.2 Atlas Connectivity from Private Subnets
**Challenge:** Private pods cannot reach external DB without controlled egress and allowlisted source IP.  
**Solution:** Route egress through NAT instance + Elastic IP; whitelist NAT EIP in MongoDB Atlas network access.

### 12.3 Private Subnet Bootstrap and Package Pulling
**Challenge:** Nodes/pods in private subnets need outbound access for dependencies and external endpoints.  
**Solution:** Private route table default route via NAT instance, preserving private inbound isolation.

### 12.4 CI/CD Drift Between Image and Manifest
**Challenge:** Pushing image alone does not guarantee cluster rollout in GitOps model.  
**Solution:** CI also updates Helm values file with exact image tag and commits change, creating declarative deployment trigger.

### 12.5 Secret Exposure Risk
**Challenge:** Storing DB credentials in Git manifests is unsafe.  
**Solution:** Use External Secrets Operator + AWS Secrets Manager and inject at runtime.

### 12.6 Security Compliance at Runtime
**Challenge:** Teams may accidentally deploy insecure pod specs.  
**Solution:** Kyverno policies enforce non-privileged containers and label requirements at admission.

### 12.7 Troubleshooting Sync and Runtime Failures
**Observed common issues (from operational docs):**
- Argo CD `OutOfSync`
- `ImagePullBackOff` or `CrashLoopBackOff`
- ingress not reachable
- terraform apply edge cases

**Resolution strategy:** standardized troubleshooting runbook (`docs/operations/troubleshooting.md`) with CLI diagnostics.

### 12.8 Configuration Consistency Across Docs and Runtime
**Challenge:** Documentation can diverge from active configuration (e.g., region/branch references).  
**Solution:** Treat infrastructure files and workflows as source-of-truth and maintain docs through change-control updates.

---

## 13. Best Practices Applied

### 13.1 Infrastructure as Code
All core cloud components are codified with modular Terraform, enabling reproducibility and controlled change review.

### 13.2 Immutable Infrastructure and Artifacts
Each deployment uses image tags derived from commit SHA and avoids mutable runtime patching on nodes/pods.

### 13.3 Separation of Concerns
- Terraform manages cloud substrate.
- Helm manages Kubernetes resource templates.
- GitHub Actions handles CI and image delivery.
- Argo CD manages desired-state synchronization.

### 13.4 Security-First Design
- IRSA for identity scoping.
- No credentials in Git.
- NetworkPolicy for runtime restrictions.
- Vulnerability scanning pre-deploy.
- Policy guardrails with Kyverno.

### 13.5 GitOps Governance
Git is the single source of truth for deployable cluster state. Manual drift is corrected automatically by Argo CD self-healing.

### 13.6 Cost-Aware Architecture
Budget-oriented engineering choices are explicit:
- NAT instance instead of NAT Gateway.
- Spot node capacity.
- lightweight monitoring profile.
- optional RDS disabled while using Atlas M0.

### 13.7 Operational Instrumentation
Monitoring and log shipping are integrated early rather than treated as post-project add-ons.

---

## 14. Future Improvements

### 14.1 Monitoring Maturity
- Add SLO/SLI dashboards and error-budget tracking.
- Add business KPI metrics and synthetic checks.

### 14.2 Centralized Logging Enhancements
- Introduce log retention lifecycle and structured logging conventions.
- Add correlation IDs and distributed tracing (OpenTelemetry).

### 14.3 Progressive Delivery
- Implement Blue/Green releases.
- Implement Canary deployments with traffic weighting and automated rollback policies.

### 14.4 Production-Grade TLS and Edge Security
- Enforce HTTPS with ACM certificates.
- Add WAF policies and rate limiting on ingress edge.

### 14.5 Terraform State and Multi-Environment Governance
- Migrate to remote state backend with locking.
- Create `prod` environment composition with stricter guardrails and approval gates.

### 14.6 Resilience and Availability
- Replace NAT instance with managed NAT Gateway for production SLA.
- Add multi-environment DR strategy and backup validation drills.

### 14.7 CI/CD Hardening
- Add signed images and provenance (SLSA/Sigstore).
- Add policy checks for Helm/Terraform before merge.
- Add environment promotion workflow (staging -> production).

### 14.8 Cost Optimization
- Introduce rightsizing dashboards.
- Add cluster autoscaler/Karpenter depending on scale profile.
- Evaluate spot interruption handling strategy in higher environments.

---

## 15. Conclusion
This project demonstrates a complete DevOps deployment architecture that goes beyond simple container deployment. It integrates cloud networking, identity security, secrets externalization, automated build-and-release pipelines, GitOps synchronization, and baseline observability.

From an engineering perspective, the strongest outcomes are:

- A modular and auditable infrastructure baseline.
- Automated CI with vulnerability gates.
- Declarative CD with drift correction.
- Secure runtime patterns (IRSA, NetworkPolicy, secret externalization).
- Production-minded operational controls (health checks, autoscaling, monitoring).

Professional value:
- This implementation is suitable for final-year engineering defense (PFE) and technical portfolio presentation because it demonstrates end-to-end ownership of infrastructure, deployment automation, and operational reliability in a modern cloud-native stack.

---

## 16. Appendix A - DevOps File-by-File Index

### 16.1 Terraform Files
- `terraform/versions.tf`: Terraform + provider version pinning.
- `terraform/environments/staging/main.tf`: staging environment composition.
- `terraform/environments/staging/variables.tf`: staging variables.
- `terraform/environments/staging/outputs.tf`: staging outputs.
- `terraform/environments/staging/backend.tf`: local backend config (with S3 template comment).
- `terraform/modules/vpc/main.tf`: VPC, subnets, IGW, NAT instance, routes.
- `terraform/modules/vpc/variables.tf`: VPC module inputs.
- `terraform/modules/vpc/outputs.tf`: VPC outputs (including NAT EIP).
- `terraform/modules/eks/main.tf`: EKS cluster and node group module wrapper.
- `terraform/modules/eks/variables.tf`: EKS module inputs.
- `terraform/modules/eks/outputs.tf`: EKS outputs including OIDC/SG IDs.
- `terraform/modules/ecr/main.tf`: ECR repo + lifecycle policy.
- `terraform/modules/ecr/variables.tf`: ECR module inputs.
- `terraform/modules/ecr/outputs.tf`: ECR outputs.
- `terraform/modules/iam/main.tf`: IRSA IAM roles/policies.
- `terraform/modules/iam/variables.tf`: IAM module inputs.
- `terraform/modules/iam/outputs.tf`: IAM output ARNs.
- `terraform/modules/rds/main.tf`: optional PostgreSQL module (currently disabled).
- `terraform/modules/rds/variables.tf`: RDS module inputs.
- `terraform/modules/rds/outputs.tf`: RDS outputs.

### 16.2 Kubernetes/Helm/Argo Files
- `helm/charts/fintrack/Chart.yaml`: chart metadata.
- `helm/charts/fintrack/values.yaml`: deployment parameters.
- `helm/charts/fintrack/templates/_helpers.tpl`: naming/labels helpers.
- `helm/charts/fintrack/templates/deployment.yaml`: application workload template.
- `helm/charts/fintrack/templates/service.yaml`: internal service template.
- `helm/charts/fintrack/templates/ingress.yaml`: external ingress template.
- `helm/charts/fintrack/templates/hpa.yaml`: autoscaling template.
- `helm/charts/fintrack/templates/externalsecret.yaml`: secret sync template.
- `helm/charts/fintrack/templates/networkpolicy.yaml`: network policy template.
- `helm/charts/fintrack/templates/serviceaccount.yaml`: service account template.
- `argocd/bootstrap/values.yaml`: Argo CD helm install values.
- `argocd/projects/default.yaml`: Argo CD project scoping.
- `argocd/applications/fintrack.yaml`: Argo CD app sync definition.

### 16.3 CI/CD Files
- `.github/workflows/deploy.yaml`: primary CI + image push + GitOps trigger pipeline.
- `.github/workflows/ci-app.yaml`: basic app CI workflow.
- `.github/workflows/cd-gitops.yaml`: placeholder GitOps workflow.

### 16.4 Security and Operations Files
- `k8s/kyverno/policies/disallow-privileged.yaml`: denies privileged pods.
- `k8s/kyverno/policies/require-labels.yaml`: enforces standard labels.
- `k8s/monitoring/prometheus-values.yaml`: monitoring stack values.
- `k8s/monitoring/fluent-bit-values.yaml`: log shipping values.
- `k8s/monitoring/alerts.yaml`: Prometheus alert rules.

### 16.5 Supporting Architecture/Decision Documentation
- `docs/infrastructure/architecture.md`: architecture overview.
- `docs/diagrams/architecture.mmd`: Mermaid architecture graph.
- `docs/infrastructure/terraform.md`: Terraform execution guide.
- `docs/infrastructure/decisions/ADR-001-region.md`: region decision.
- `docs/infrastructure/decisions/ADR-002-nat-instance.md`: NAT design decision.
- `docs/infrastructure/decisions/ADR-003-mongodb-atlas.md`: DB strategy decision.
- `docs/infrastructure/decisions/ADR-004-security.md`: security strategy decision.
- `docs/operations/monitoring.md`: monitoring operations guide.
- `docs/operations/security.md`: security operations summary.
- `docs/operations/troubleshooting.md`: troubleshooting runbook.

---

## 17. Appendix B - Operational Command Reference

### 17.1 Terraform
```bash
cd terraform/environments/staging
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

### 17.2 EKS Access
```bash
aws eks update-kubeconfig --name fintrack-staging --region eu-north-1
kubectl get nodes
```

### 17.3 Argo CD Bootstrap
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace -f argocd/bootstrap/values.yaml
kubectl apply -f argocd/projects/default.yaml
kubectl apply -f argocd/applications/fintrack.yaml
```

### 17.4 Monitoring Stack
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f k8s/monitoring/prometheus-values.yaml
kubectl apply -f k8s/monitoring/alerts.yaml
```

### 17.5 Fluent Bit
```bash
helm repo add fluent https://fluent.github.io/helm-charts
helm install fluent-bit fluent/fluent-bit -n logging --create-namespace -f k8s/monitoring/fluent-bit-values.yaml
```

### 17.6 Validation Checklist
```bash
kubectl get pods -A
kubectl get ingress -A
kubectl get hpa -A
kubectl get externalsecret -A
kubectl get networkpolicy -A
```

---

## Final Note
This document intentionally excludes application business logic and source implementation details, and focuses exclusively on DevOps, cloud architecture, infrastructure, CI/CD, and operations engineering.
