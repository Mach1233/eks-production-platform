# -----------------------------------------------------------------------------
# Staging Environment Outputs
# -----------------------------------------------------------------------------

# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "nat_public_ip" {
  description = "NAT instance EIP (whitelist in MongoDB Atlas)"
  value       = module.vpc.nat_public_ip
}

# EKS
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

# ECR
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

# IAM
output "eso_role_arn" {
  description = "ESO IRSA role ARN"
  value       = module.iam.eso_role_arn
}

output "fluent_bit_role_arn" {
  description = "Fluent Bit IRSA role ARN"
  value       = module.iam.fluent_bit_role_arn
}

output "alb_controller_role_arn" {
  description = "ALB Controller IRSA role ARN"
  value       = module.iam.alb_controller_role_arn
}
