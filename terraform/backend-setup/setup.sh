#!/bin/bash
# setup.sh - Helper script to create S3 bucket and DynamoDB table for Terraform backend

set -e

REGION="eu-north-1"
BUCKET_NAME="fintrack-terraform-state-$(date +%s)" # Unique bucket name
TABLE_NAME="fintrack-terraform-locks"

echo "Creating S3 bucket: $BUCKET_NAME in $REGION..."
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

echo "Enabling encryption on bucket..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

echo "Enabling versioning on bucket..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

echo "Creating DynamoDB table: $TABLE_NAME in $REGION..."
aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --region "$REGION"

echo "----------------------------------------------------------------"
echo "Setup complete!"
echo "Update terraform/environments/staging/backend.tf with:"
echo "bucket         = \"$BUCKET_NAME\""
echo "dynamodb_table = \"$TABLE_NAME\""
echo "----------------------------------------------------------------"
