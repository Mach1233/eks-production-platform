variable "enabled" {
  description = "Whether to create the RDS instance (default: false, using Atlas)"
  type        = bool
  default     = false
}

variable "identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "app_db"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "eks_node_sg_id" {
  description = "EKS node security group ID (for ingress rule)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
