provider "aws" {
  region = "eu-north-1"
}

locals {
  tags = {
    Environment = "staging"
    Project     = "cloud-native-eks-platform"
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name            = "eks-staging"
  cidr            = "10.0.0.0/16"
  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  tags            = local.tags
}

module "eks" {
  source     = "../../modules/eks"
  depends_on = [module.vpc]

  cluster_name    = "eks-staging"
  cluster_version = "1.30"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  tags            = local.tags
}

module "rds" {
  source     = "../../modules/rds"
  depends_on = [module.vpc, module.eks]

  identifier     = "eks-staging-db"
  instance_class = "db.t3.micro"
  db_name        = "app_db"
  username       = "dbadmin"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  eks_sg_id       = module.eks.node_security_group_id
}
