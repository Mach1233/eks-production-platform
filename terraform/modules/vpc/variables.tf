# -----------------------------------------------------------------------------
# VPC Module Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name prefix for all VPC resources"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "nat_instance_type" {
  description = "EC2 instance type for NAT instance (ARM recommended for cost)"
  type        = string
  default     = "t4g.micro"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
