data "aws_region" "current" {
  region = var.region
}

data "aws_partition" "current" {}

# =============================================================================
# AMI Lookup (SSM Parameter)
# =============================================================================
# Always read (when `create = true`), even if `ami` is set: `var.ami` can be a
# value only known after apply, and it cannot drive `count`. The explicit `ami`
# still takes precedence in `local.ami`.

data "aws_ssm_parameter" "ami" {
  count = local.create ? 1 : 0

  region = var.region

  name = var.ami_ssm_parameter
}

# =============================================================================
# Subnet Lookup (used to resolve the VPC of the managed security group)
# =============================================================================

data "aws_subnet" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  id = var.subnet_id
}
