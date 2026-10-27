# =============================================================================
# Spot Instance Example
# =============================================================================
# Launches a one-time Spot instance through instance_market_options:
# - Capped maximum price
# - Terminated when interrupted (required for one-time requests)
# - Unlimited CPU credits on a burstable instance type
# =============================================================================

provider "aws" {
  region = var.region
}

module "ec2_spot" {
  source = "../../ec2"

  account_name = var.account_name
  project_name = var.project_name

  instance_type = "t3.small"
  subnet_id     = var.subnet_id
  cpu_credits   = "unlimited"

  instance_market_options = {
    market_type = "spot"
    spot_options = {
      max_price                      = var.spot_max_price
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  root_block_device = {
    encrypted = true
    type      = "gp3"
    size      = 20
  }

  security_group_ingress_rules = {
    https = {
      description = "Allow HTTPS from VPC"
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = var.vpc_cidr
    }
  }

  tags_common = var.tags
}
