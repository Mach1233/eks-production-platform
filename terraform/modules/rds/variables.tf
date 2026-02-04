variable "identifier" { type = string }
variable "instance_class" { type = string }
variable "db_name" { type = string }
variable "username" { type = string }
variable "vpc_id" { type = string }
variable "private_subnets" { type = list(string) }
variable "eks_sg_id" { type = string }
