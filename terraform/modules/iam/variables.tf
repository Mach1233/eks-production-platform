# -----------------------------------------------------------------------------
# IAM Module Variables
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN from EKS module"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider URL (without https://)"
  type        = string
}

variable "eso_namespace" {
  description = "Kubernetes namespace for External Secrets Operator"
  type        = string
  default     = "external-secrets"
}

variable "eso_service_account" {
  description = "Kubernetes service account for ESO"
  type        = string
  default     = "external-secrets"
}

variable "fluent_bit_namespace" {
  description = "Kubernetes namespace for Fluent Bit"
  type        = string
  default     = "logging"
}

variable "fluent_bit_service_account" {
  description = "Kubernetes service account for Fluent Bit"
  type        = string
  default     = "fluent-bit"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
