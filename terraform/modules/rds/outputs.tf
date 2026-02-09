output "db_instance_address" {
  value = module.rds.db_instance_address
}

output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_password" {
  value     = random_password.master.result
  sensitive = true
}
