# =============================================================================
# Multiple Instances Example
# =============================================================================
# The module manages a single instance per invocation. Several instances are
# created with for_each in the caller; `name_suffix` keeps generated names
# (instance, security group, IAM role, volumes) unique per key.
# =============================================================================

provider "aws" {
  region = var.region
}

locals {
  instances = {
    web-1 = {
      instance_type = "t3.micro"
      subnet_id     = var.subnet_ids[0]
      root_size     = 20
    }
    web-2 = {
      instance_type = "t3.micro"
      subnet_id     = var.subnet_ids[1 % length(var.subnet_ids)]
      root_size     = 20
    }
    worker = {
      instance_type = "t3.small"
      subnet_id     = var.subnet_ids[0]
      root_size     = 50
    }
  }
}

# Shared security group for all instances (the module-managed one is disabled)
resource "aws_security_group" "shared" {
  name        = "${var.account_name}-${var.project_name}-shared"
  description = "Shared security group for ${var.project_name} instances"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.account_name}-${var.project_name}-shared"
  })
}

resource "aws_vpc_security_group_egress_rule" "shared_all" {
  security_group_id = aws_security_group.shared.id

  description = "Allow all outbound"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

module "ec2" {
  source   = "../../ec2"
  for_each = local.instances

  account_name = var.account_name
  project_name = var.project_name
  name_suffix  = each.key

  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.shared.id]

  root_block_device = {
    encrypted = true
    type      = "gp3"
    size      = each.value.root_size
  }

  instance_tags = {
    Role = each.key
  }

  tags_common = var.tags
}
