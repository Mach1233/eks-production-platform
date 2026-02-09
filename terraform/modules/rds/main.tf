resource "random_password" "master" {
  length  = 20
  special = false
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier        = var.identifier
  engine            = "postgres"
  engine_version    = "15"
  family            = "postgres15"
  instance_class    = var.instance_class
  allocated_storage = 20
  db_name           = var.db_name
  username          = var.username
  password          = random_password.master.result
  port              = 5432

  vpc_security_group_ids = [aws_security_group.rds.id]
  subnet_ids             = var.private_subnets
  multi_az               = true
  storage_encrypted      = true
  publicly_accessible    = false

  backup_retention_period = 7
}

resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.identifier}-sg"
  }
}

resource "aws_security_group_rule" "allow_eks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.eks_sg_id
}
