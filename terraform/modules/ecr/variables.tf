variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "fintrack"
}

variable "image_retention_count" {
  description = "Max number of images to keep (lifecycle policy)"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
