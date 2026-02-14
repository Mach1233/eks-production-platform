# Terraform Apply Guide

## Prerequisites
- [Terraform >= 1.6](https://developer.hashicorp.com/terraform/install) installed
- AWS CLI configured for `eu-north-1`:
  ```bash
  aws configure
  # Region: eu-north-1
  # Output: json
  ```
- AWS credentials with permissions for: VPC, EC2, EKS, ECR, IAM, Secrets Manager

## Directory Structure
```
terraform/
├── environments/
│   └── staging/        # ← Run terraform from here
│       ├── main.tf     # Module calls
│       ├── variables.tf
│       ├── outputs.tf
│       └── backend.tf  # State storage (local or S3)
├── modules/
│   ├── vpc/            # VPC + NAT instance
│   ├── eks/            # EKS cluster + node group
│   ├── ecr/            # Container registry
│   ├── iam/            # IRSA roles
│   └── rds/            # PostgreSQL (disabled)
└── versions.tf         # Provider pinning
```

## Step-by-Step

### 1. Initialize Terraform
```bash
cd terraform/environments/staging
terraform init
```

### 2. Review the Plan
```bash
terraform plan -out=tfplan
```
Review the output carefully. Expected resources:
- VPC + subnets (public/private across 3 AZs)
- NAT instance (`t4g.micro`) + EIP
- Internet Gateway + route tables
- EKS cluster + managed node group (spot `t3.micro`)
- ECR repository
- IAM IRSA roles

### 3. Apply (When Ready)
```bash
terraform apply tfplan
```

> ⚠️ **Cost Warning**: EKS control plane costs ~€0.10/hour (~€7/month).
> NAT instance ~€3/month. Total ~€10-15/month.

### 4. Configure kubectl
```bash
aws eks update-kubeconfig --name eks-staging --region eu-north-1
kubectl get nodes
```

## Useful Commands

| Command | Purpose |
|---------|---------|
| `terraform plan` | Preview changes |
| `terraform apply` | Apply changes |
| `terraform destroy` | Tear down everything |
| `terraform state list` | List managed resources |
| `terraform output` | Show outputs (VPC ID, EKS endpoint, etc.) |
| `terraform fmt -recursive` | Format all `.tf` files |
| `terraform validate` | Validate syntax |

## State Management

Currently using **local backend** (file-based state). For team/production use:
```hcl
# backend.tf — uncomment after creating S3 bucket + DynamoDB table
backend "s3" {
  bucket         = "fintrack-terraform-state"
  key            = "staging/terraform.tfstate"
  region         = "eu-north-1"
  dynamodb_table = "terraform-locks"
  encrypt        = true
}
```

## Teardown
```bash
terraform destroy
# Type "yes" to confirm
```

> 💡 Always destroy when not actively testing to avoid charges.
