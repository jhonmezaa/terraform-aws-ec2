# =============================================================================
# Session Manager Example
# =============================================================================
# Private instance reachable only through AWS Systems Manager Session Manager:
# - No key pair, no inbound rules, no public IP
# - IAM instance profile with AmazonSSMManagedInstanceCore
# - Egress restricted to HTTPS towards the VPC (interface endpoints)
# - Interface VPC endpoints for ssm, ssmmessages and ec2messages
# =============================================================================

provider "aws" {
  region = var.region
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

module "ec2" {
  source = "../../ec2"

  account_name = var.account_name
  project_name = var.project_name

  instance_type               = "t3.micro"
  subnet_id                   = var.private_subnet_ids[0]
  vpc_id                      = var.vpc_id
  associate_public_ip_address = false

  create_iam_instance_profile = true
  iam_role_description        = "Session Manager access for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # No ingress rules: access happens through Session Manager only
  security_group_egress_rules = {
    vpc_endpoints = {
      description = "Allow HTTPS to VPC interface endpoints"
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = data.aws_vpc.this.cidr_block
    }
  }

  tags_common = var.tags
}

# =============================================================================
# Supporting Resources - VPC Interface Endpoints
# =============================================================================

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.account_name}-${var.project_name}-ssm-endpoints"
  description = "HTTPS from the VPC to SSM interface endpoints"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.account_name}-${var.project_name}-ssm-endpoints"
  })
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https" {
  security_group_id = aws_security_group.vpc_endpoints.id

  description = "HTTPS from VPC"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = data.aws_vpc.this.cidr_block
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = toset(["ssm", "ssmmessages", "ec2messages"])

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.account_name}-${var.project_name}-${each.key}"
  })
}
