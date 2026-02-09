terraform {
  # Switched to local backend for initial testing. 
  # For production, create a unique S3 bucket and DynamoDB table, then uncomment below:
  # backend "s3" {
  #   bucket = "your-unique-terraform-state-bucket"
  #   key    = "staging/terraform.tfstate"
  #   region = "eu-north-1"
  #   # dynamodb_table = "terraform-locks"
  # }
  backend "local" {
    path = "terraform.tfstate"
  }
}
