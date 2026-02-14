# -----------------------------------------------------------------------------
# ECR Module — Elastic Container Registry
# Stores Docker images for FinTrack app
# Includes lifecycle policy to limit image count (cost control)
# -----------------------------------------------------------------------------

resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE" # Allow tag overwrites (e.g., :latest)

  image_scanning_configuration {
    scan_on_push = true # Auto-scan for vulnerabilities
  }

  tags = var.tags
}

# Lifecycle policy — keep only last N images to save storage costs
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last ${var.image_retention_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
