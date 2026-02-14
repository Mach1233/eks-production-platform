output "db_instance_address" {
  description = "RDS instance address"
  value       = var.enabled ? aws_db_instance.main[0].address : ""
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = var.enabled ? aws_db_instance.main[0].endpoint : ""
}

output "db_password" {
  description = "Generated master password"
  value       = var.enabled ? random_password.master[0].result : ""
  sensitive   = true
}
