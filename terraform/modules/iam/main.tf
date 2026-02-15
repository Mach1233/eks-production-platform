# -----------------------------------------------------------------------------
# IAM Module — IRSA Roles (IAM Roles for Service Accounts)
# Creates least-privilege IAM roles for Kubernetes service accounts:
# - External Secrets Operator (read from AWS Secrets Manager)
# - Fluent Bit (write logs to CloudWatch)
# - AWS Load Balancer Controller (manage ALB/NLB)
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# ---------------------
# External Secrets Operator — IRSA Role
# Allows ESO to read secrets from AWS Secrets Manager
# ---------------------
resource "aws_iam_role" "eso" {
  name = "${var.cluster_name}-eso-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
            "${var.oidc_provider}:sub" = "system:serviceaccount:${var.eso_namespace}:${var.eso_service_account}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "eso" {
  name = "${var.cluster_name}-eso-policy"
  role = aws_iam_role.eso.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:fintrack/*"
      }
    ]
  })
}

# ---------------------
# Fluent Bit — IRSA Role
# Allows Fluent Bit to send logs to CloudWatch
# ---------------------
resource "aws_iam_role" "fluent_bit" {
  name = "${var.cluster_name}-fluent-bit-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
            "${var.oidc_provider}:sub" = "system:serviceaccount:${var.fluent_bit_namespace}:${var.fluent_bit_service_account}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "fluent_bit" {
  name = "${var.cluster_name}-fluent-bit-policy"
  role = aws_iam_role.fluent_bit.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/fintrack/*"
      }
    ]
  })
}

# ---------------------
# AWS Load Balancer Controller — IRSA Role
# Allows ALB controller to manage load balancers
# ---------------------
resource "aws_iam_role" "alb_controller" {
  name = "${var.cluster_name}-alb-controller-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# ALB Controller needs broad EC2/ELB permissions — use AWS managed policy
resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = "arn:aws:iam::policy/ElasticLoadBalancingFullAccess"
}
