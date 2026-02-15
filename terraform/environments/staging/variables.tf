# -----------------------------------------------------------------------------
# Staging Environment Variables
# -----------------------------------------------------------------------------

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Deployment environment (e.g., staging, prod)"
  type        = string
  default     = "staging"
}
