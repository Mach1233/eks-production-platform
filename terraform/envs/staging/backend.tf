terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "staging/terraform.tfstate"
    region = "us-east-1"
  }
}
