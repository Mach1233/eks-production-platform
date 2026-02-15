terraform {
  backend "s3" {
    # Replace with your actual bucket name and region
    # bucket         = "fintrack-terraform-state-med0120"
    # key            = "staging/terraform.tfstate"
    # region         = "eu-north-1"
    # dynamodb_table = "fintrack-terraform-locks"
    # encrypt        = true
  }
}
