# -----------------------------------------------------------------------------
# EKS Module — Managed Kubernetes Cluster
# Uses community module for EKS (proven, well-maintained)
# Cost: Control plane ~€7/month, nodes: spot t3.micro ~€3/month
# -----------------------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Endpoint access
  cluster_endpoint_public_access  = true # For kubectl from local
  cluster_endpoint_private_access = true # For pods to reach API server

  # IRSA — enables IAM Roles for Service Accounts (least privilege)
  enable_irsa = true

  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Managed node group — spot instances for cost savings
  eks_managed_node_groups = {
    spot = {
      name           = "${var.cluster_name}-spot"
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
      instance_types = var.node_instance_types
      capacity_type  = var.node_capacity_type # SPOT for ~60-70% savings

      labels = {
        Environment = "staging"
        NodeType    = "spot"
      }

      tags = var.tags
    }
  }

  tags = var.tags
}
