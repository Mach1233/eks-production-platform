# -----------------------------------------------------------------------------
# IAM Module Outputs
# -----------------------------------------------------------------------------

output "eso_role_arn" {
  description = "IAM role ARN for External Secrets Operator"
  value       = aws_iam_role.eso.arn
}

output "fluent_bit_role_arn" {
  description = "IAM role ARN for Fluent Bit"
  value       = aws_iam_role.fluent_bit.arn
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}
