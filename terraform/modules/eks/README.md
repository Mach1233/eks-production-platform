# EKS Module

Creates an EKS cluster with managed node groups (Spot instances for cost savings) and IRSA support.

## Resources Created
- EKS cluster with public + private endpoint access
- Managed node group (default: `t3.micro` SPOT)
- IRSA (IAM Roles for Service Accounts) — enabled by default
- Cluster addons: CoreDNS, kube-proxy, VPC-CNI

## Cost
- Control plane: ~€7/month (€0.10/hr)
- Spot `t3.micro` nodes: ~€1-3/month each
- Total: ~€10-13/month for basic setup

## Usage
```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name       = "eks-staging"
  cluster_version    = "1.30"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  node_instance_types = ["t3.micro"]
  node_capacity_type  = "SPOT"
  node_min_size       = 1
  node_max_size       = 3
  tags               = { Environment = "staging" }
}
```

## Outputs
| Name | Description |
|------|-------------|
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | API server endpoint |
| `oidc_provider_arn` | ARN for IRSA roles |
| `node_security_group_id` | Node SG ID |
