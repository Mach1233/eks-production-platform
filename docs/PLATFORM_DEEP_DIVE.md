# FinTrack Platform: Professional Deep Dive & File Analysis

## **1. Executive Overview**
This document serves as the **definitive technical reference** for the FinTrack Platform. Unlike high-level summaries, this guide breaks down **every significant file** in the codebase, explaining its specific role, why it was created, and the technical decisions ("what makes it") embedded within.

---

## **2. Repository Root & Configuration**
*Foundational files for project governance, automation, and hygiene.*

| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `README.md` | Entry Point | To provide immediate context, status, and navigation for new developers. | Badges for CI/CD status; Quick links to deep dives and how-tos. |
| `.gitignore` | git Configuration | To prevent sensitive/junk files (node_modules, .tfstate, .env) from polluting the repo. | explicitly excludes `.terraform/`, `terraform.tfstate`, and `node_modules/`. |
| `.pre-commit-config.yaml` | Automation Hook | To enforce code quality *before* commit (fail fast). | Runs `terraform fmt` to standardize HCL; `check-yaml` for syntax validation; `trailing-whitespace` fixer. |
| `CONTRIBUTING.md` | Governance | To standardize how developers collaborate. | Defines "Conventional Commits" standard (feat, fix, chore) required for semantic versioning. |
| `LICENSE` | Legal | To define usage rights. | standard MIT License (open source, permissive). |
| `app/.env.example` | Template | To document required environment variables without leaking secrets. | Lists `MONGODB_URI` but leaves value empty. |

---

## **3. Infrastructure as Code (Terraform)**
*Implements the AWS infrastructure. Modular design for reusability.*

### **3.1. Root Terraform**
| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `terraform/versions.tf` | Dependency Lock | To ensure reproducible infrastructure builds by pinning provider versions. | Pins `hashicorp/aws` to `~> 5.0`; Enforces Terraform CLI `>= 1.6`. |

### **3.2. Module: VPC (`terraform/modules/vpc`)**
*Role: Network Foundation*
| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `main.tf` | Resource Def | To define the network topology. | **Custom NAT Instance**: Defines an `aws_instance` (t4g.micro) instead of NAT Gateway to save ~$30/mo. `user_data` script enables IP forwarding. |
| `variables.tf` | Interface | To make the module reusable across envs. | Accepts `cidr`, `public_subnets`, `private_subnets`. Defaults NAT to `t4g.micro` (ARM). |
| `outputs.tf` | data Export | To pass connection data to other modules. | Exports `vpc_id` for EKS; `nat_public_ip` for MongoDB Atlas whitelist. |

### **3.3. Module: EKS (`terraform/modules/eks`)**
*Role: Kubernetes Cluster*
| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `main.tf` | Resource Def | To provision the Control Plane and Worker Nodes. | **Spot Instances**: Configures `eks_managed_node_groups` with `capacity_type = "SPOT"` and `t3.micro`. **IRSA**: Enables `enable_irsa = true` for fine-grained pod permissions. |
| `variables.tf` | Interface | Configuration flexibility. | Allows setting `node_min_size`, `node_max_size` to control cost/scale. |
| `outputs.tf` | data Export | Connectivity details. | Exports `cluster_endpoint` and `oidc_provider_arn` (critical for IAM). |

### **3.4. Module: IAM (`terraform/modules/iam`)**
*Role: Security & Permissions*
| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `main.tf` | Resource Def | To define "Roles for Service Accounts" (IRSA). | Creates roles for **ESO** (SecretsReader), **FluentBit** (CloudWatchWriter), **ALB** (LoadBalancerAdmin). Uses `sts:AssumeRoleWithWebIdentity` condition on OIDC subject. |

### **3.5. Environment: Staging (`terraform/environments/staging`)**
*Role: The "Glue" that wires modules together.*
| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `main.tf` | Composition | To deploy the specific staging environment. | Instantiates VPC, EKS, ECR, IAM. Sets RDS `enabled = false`. Passes `t4g.micro` to VPC and `SPOT` to EKS. |
| `terraform.tfvars` | Configuration | To inject environment-specific values. | Sets `environment = "staging"`. |

---

## **4. Helm Chart (`helm/charts/fintrack`)**
*Abstractions for Kubernetes Manifests. Defines HOW the app runs.*

| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `Chart.yaml` | Metadata | To define the chart version and name. | Version `0.1.0`. |
| `values.yaml` | Defaults | To provide default configuration for the app. | `replicaCount: 2`; `hpa.enabled: true`; `ingress.className: alb`. Defines `externalSecret` config. |
| `templates/deployment.yaml` | Workload | To run the Next.js container. | **Probes**: Liveness/Readiness probes Configured. **Secret Injection**: Uses `envFrom` referring to the ExternalSecret. |
| `templates/service.yaml` | Networking | To provide a stable internal IP. | Type `ClusterIP` (internal only). Exposes port 80 targeting 3000. |
| `templates/ingress.yaml` | Expose | To expose the app to the internet. | Uses AWS Load Balancer Controller annotations (`alb.ingress.kubernetes.io/scheme: internet-facing`). |
| `templates/hpa.yaml` | Scaling | To auto-scale based on load. | Scales between 2-5 replicas if CPU > 70%. |
| `templates/externalsecret.yaml`| Security | To sync AWS Secrets to K8s. | Defines `ExternalSecret` CRD that tells ESO to fetch `fintrack/mongodb-uri` from AWS Secrets Manager. |
| `templates/networkpolicy.yaml`| Security | To firewall the pods. | **Zero Trust**: Ingress only from ALB; Egress only to DNS, HTTPS, MongoDB. |

---

## **5. GitOps & ArgoCD (`argocd/`)**
*Defines HOW the app is delivered.*

| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `bootstrap/values.yaml` | install Config | To customize the ArgoCD installation itself. | Disables Dex/Notifications to save resources. Sets server to `LoadBalancer` (or NodePort). |
| `projects/default.yaml` | Governance | To restrict what apps can do. | **Scoped Project**: Only allows deployments to `fintrack` namespace. Prevents access to `kube-system`. |
| `applications/fintrack.yaml`| App Def | To tell ArgoCD *what* to sync. | Points to `helm/charts/fintrack` in `develop` branch. **Auto-Sync**: Enabled with `prune=true` (deletes orphaned resources) and `selfHeal=true` (undoes manual drift). |

---

## **6. CI/CD Pipeline (`.github/workflows/deploy.yaml`)**
*Automation for Building and updating.*

| Role | Why Created? | Key Implementation Details |
|------|--------------|----------------------------|
| **Job: Build** | Artifact Creation | Compiles app to Docker image. | Uses `docker/setup-buildx-action` for caching. |
| **Job: Scan** | Security | To find vulnerabilities before deploy. | Uses **Trivy**. Fails on `CRITICAL` severity CVEs. |
| **Job: Push** | Artifact Store | To host the image. | Uses **OIDC** (`aws-actions/configure-aws-credentials`). No static IAM keys. Pushes to ECR private repo. |
| **Job: Update Helm**| Deployment Trigger| To implement GitOps. | Modifies `values.yaml` with `sed` to update `image.tag` config, then commits back to the repo. |

---

## **7. Security Policies (`k8s/kyverno/`)**
*Cluster-wide Policy Enforcement.*

| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `disallow-privileged.yaml`| Enforcement | To prevent high-risk containers. | Validates that `securityContext.privileged` is NOT `true`. |
| `require-labels.yaml` | Governance | To ensure organizational standards. | Enforces that every Deployment has `app.kubernetes.io/name` and `instance` labels for cost allocation/tracking. |

---

## **8. Monitoring (`k8s/monitoring/`)**
*Observability Stack.*

| File | Role | Why Created? | Key Implementation Details |
|------|------|--------------|----------------------------|
| `prometheus-values.yaml`| Config | Lightweight Prometheus stack. | Reduces retention to 3 days (save storage). Configures Persistent Volume for metrics integrity. |
| `fluent-bit-values.yaml`| Log Shipping | To send logs to CloudWatch. | Configures `[OUTPUT]` plugin for `cloudwatch_logs`. Uses IRSA annotation for permissions. |
| `alerts.yaml` | Alerting | To notify on failures. | Defines PromQL rules: `HighCPUUsage` (>80%), `PodCrashLooping` (restarts), `PodNotReady`. |
