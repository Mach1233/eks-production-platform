# -----------------------------------------------------------------------------
# RDS Module — Optional PostgreSQL Database
# Disabled by default (FinTrack uses MongoDB Atlas)
# Enable via: enabled = true in staging/main.tf
# -----------------------------------------------------------------------------

resource "random_password" "master" {
  count   = var.enabled ? 1 : 0
  length  = 20
  special = false
}

resource "aws_db_subnet_group" "main" {
  count = var.enabled ? 1 : 0

  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  count = var.enabled ? 1 : 0

  name_prefix = "${var.identifier}-rds-"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.identifier}-rds-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_eks" {
  count = var.enabled ? 1 : 0

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds[0].id
  source_security_group_id = var.eks_node_sg_id
  description              = "Allow PostgreSQL from EKS nodes"
}

resource "aws_db_instance" "main" {
  count = var.enabled ? 1 : 0

  identifier        = var.identifier
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = var.instance_class
  allocated_storage = 20

  db_name  = var.db_name
  username = var.username
  password = random_password.master[0].result
  port     = 5432

  vpc_security_group_ids = [aws_security_group.rds[0].id]
  db_subnet_group_name   = aws_db_subnet_group.main[0].name

  multi_az            = false # Single AZ for cost savings in staging
  storage_encrypted   = true
  publicly_accessible = false
  skip_final_snapshot = true

  backup_retention_period = 7

  tags = var.tags
}
