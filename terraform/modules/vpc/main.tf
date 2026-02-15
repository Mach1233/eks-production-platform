# -----------------------------------------------------------------------------
# VPC Module — Pure Terraform (no community module)
# Creates: VPC, public/private subnets, IGW, NAT instance (t4g.micro ARM),
#          route tables, EIP, security groups
# Cost: NAT instance ~€3/month vs NAT Gateway ~€30-45/month
# See: docs/decisions/ADR-002-nat-instance.md
# -----------------------------------------------------------------------------

# ---------------------
# VPC
# ---------------------
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

# ---------------------
# Internet Gateway
# ---------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# ---------------------
# Public Subnets
# ---------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                = "${var.name}-public-${var.azs[count.index]}"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  })
}

# ---------------------
# Private Subnets
# ---------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name                                = "${var.name}-private-${var.azs[count.index]}"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  })
}

# ---------------------
# Public Route Table
# ---------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------------
# NAT Instance (ARM t4g.micro — ~€3/month)
# Replaces NAT Gateway (~€30-45/month) for cost savings
# ---------------------

# Find latest Amazon Linux 2 ARM AMI
data "aws_ami" "amazon_linux_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for NAT instance
resource "aws_security_group" "nat" {
  name_prefix = "${var.name}-nat-"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

  # Allow all outbound traffic (NAT needs to forward to internet)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  # Allow inbound from private subnets (traffic to be NAT'd)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnets
    description = "Allow from private subnets"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-nat-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# NAT Instance
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.amazon_linux_arm.id
  instance_type               = var.nat_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.nat.id]
  associate_public_ip_address = true
  source_dest_check           = false # Required for NAT

  # Auto-configure IP forwarding and masquerade
  user_data = <<-EOF
    #!/bin/bash
    set -e
    # Enable IP forwarding
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -w net.ipv4.ip_forward=1
    # Configure iptables for NAT
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    # Persist iptables rules
    yum install -y iptables-services
    service iptables save
  EOF

  tags = merge(var.tags, {
    Name = "${var.name}-nat-instance"
  })
}

# Elastic IP for NAT instance (static IP for Atlas whitelist)
resource "aws_eip" "nat" {
  domain   = "vpc"
  instance = aws_instance.nat.id

  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip"
  })

  depends_on = [aws_internet_gateway.main]
}

# ---------------------
# Private Route Table (routes through NAT instance)
# ---------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }

  tags = merge(var.tags, {
    Name = "${var.name}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
