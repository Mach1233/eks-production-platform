# VPC Module

Creates a production-ready VPC with public/private subnets, NAT instance, and EKS-ready subnet tags.

## Resources Created
- VPC with DNS support
- Public subnets (1 per AZ) with Internet Gateway
- Private subnets (1 per AZ) routed through NAT instance
- NAT instance (`t4g.micro` ARM) with EIP and auto-config user_data
- Security group for NAT instance
- Route tables for public and private subnets

## Cost
- NAT instance: ~€3/month (vs ~€30-45 for NAT Gateway)
- See [ADR-002](../../docs/decisions/ADR-002-nat-instance.md)

## Usage
```hcl
module "vpc" {
  source = "../../modules/vpc"

  name            = "eks-staging"
  cidr            = "10.0.0.0/16"
  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  tags            = { Environment = "staging" }
}
```

## Outputs
| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `nat_public_ip` | NAT EIP (whitelist in MongoDB Atlas) |
