# -----------------------------------------------------------------------------
# versions.tf — Provider and Terraform version pinning
# Note: Provider configuration (region) belongs in environments/, not here.
# This file just pins the required versions for all modules.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
