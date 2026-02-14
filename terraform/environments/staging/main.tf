# -----------------------------------------------------------------------------
# Staging Environment — Main Configuration
# Calls all Terraform modules for the staging deployment
# Region: eu-north-1 | Cost target: ~€10-15/month
# -----------------------------------------------------------------------------

provider "aws" {
  region = "eu-north-1"
}

locals {
  cluster_name = "fintrack-staging"

  tags = {
    Environment = "staging"
    Project     = "fintrack"
    ManagedBy   = "Terraform"
  }
}

# ---------------------
# VPC — Pure Terraform + NAT Instance
# ---------------------
module "vpc" {
  source = "../../modules/vpc"

  name              = local.cluster_name
  cidr              = "10.0.0.0/16"
  azs               = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  nat_instance_type = "t4g.micro" # ARM-based, ~€3/month
  tags              = local.tags
}

# ---------------------
# EKS — Spot Instances
# ---------------------
module "eks" {
  source     = "../../modules/eks"
  depends_on = [module.vpc]

  cluster_name        = local.cluster_name
  cluster_version     = "1.30"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_types = ["t3.micro"]
  node_capacity_type  = "SPOT"
  node_min_size       = 1
  node_max_size       = 3
  node_desired_size   = 2
  tags                = local.tags
}

# ---------------------
# ECR — Container Registry
# ---------------------
module "ecr" {
  source = "../../modules/ecr"

  repository_name       = "fintrack"
  image_retention_count = 10
  tags                  = local.tags
}

# ---------------------
# IAM — IRSA Roles
# ---------------------
module "iam" {
  source     = "../../modules/iam"
  depends_on = [module.eks]

  cluster_name      = local.cluster_name
  region            = "eu-north-1"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider     = module.eks.oidc_provider
  tags              = local.tags
}

# ---------------------
# RDS — Disabled by default (using MongoDB Atlas)
# Set enabled = true to provision PostgreSQL
# ---------------------
module "rds" {
  source     = "../../modules/rds"
  depends_on = [module.vpc, module.eks]

  enabled            = false # Using MongoDB Atlas M0 (free)
  identifier         = "${local.cluster_name}-db"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_node_sg_id     = module.eks.node_security_group_id
  tags               = local.tags
}
