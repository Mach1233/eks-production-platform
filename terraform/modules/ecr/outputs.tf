output "repository_url" {
  description = "ECR repository URL (for docker push)"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.main.arn
}

output "registry_id" {
  description = "The registry ID (AWS account ID)"
  value       = aws_ecr_repository.main.registry_id
}
