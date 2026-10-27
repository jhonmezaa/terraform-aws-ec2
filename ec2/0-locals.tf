locals {
  # =============================================================================
  # Region Prefix Mapping
  # =============================================================================

  region_prefix_map = {
    # US Regions
    "us-east-1" = "ause1"
    "us-east-2" = "ause2"
    "us-west-1" = "ausw1"
    "us-west-2" = "ausw2"
    # EU Regions
    "eu-west-1"    = "euwe1"
    "eu-west-2"    = "euwe2"
    "eu-west-3"    = "euwe3"
    "eu-central-1" = "euce1"
    "eu-central-2" = "euce2"
    "eu-north-1"   = "euno1"
    "eu-south-1"   = "euso1"
    "eu-south-2"   = "euso2"
    # AP Regions
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "apso1"
    "ap-south-2"     = "apso2"
    "ap-east-1"      = "apea1"
    # SA Regions
    "sa-east-1" = "saea1"
    # CA Regions
    "ca-central-1" = "cace1"
    "ca-west-1"    = "cawe1"
    # ME Regions
    "me-south-1"   = "meso1"
    "me-central-1" = "mece1"
    # AF Regions
    "af-south-1" = "afso1"
    # IL Regions
    "il-central-1" = "ilce1"
  }

  region_prefix = var.region_prefix != null ? var.region_prefix : lookup(
    local.region_prefix_map,
    data.aws_region.current.region,
    data.aws_region.current.region
  )

  # Name prefix: includes region prefix with trailing dash, or empty string
  name_prefix = var.use_region_prefix ? "${local.region_prefix}-" : ""

  # Optional suffix appended to every generated name (useful with for_each in the caller)
  name_suffix = var.name_suffix != null ? "-${var.name_suffix}" : ""

  # =============================================================================
  # Creation Flags
  # =============================================================================

  create                      = var.create
  create_security_group       = local.create && var.create_security_group && var.network_interface == null
  create_iam_instance_profile = local.create && var.create_iam_instance_profile
  create_eip                  = local.create && var.create_eip

  # =============================================================================
  # Resource Naming
  # =============================================================================

  instance_name       = coalesce(var.name, "${local.name_prefix}ec2-${var.account_name}-${var.project_name}${local.name_suffix}")
  security_group_name = coalesce(var.security_group_name, "${local.name_prefix}sg-ec2-${var.account_name}-${var.project_name}${local.name_suffix}")
  eip_name            = coalesce(var.eip_name, "${local.name_prefix}eip-ec2-${var.account_name}-${var.project_name}${local.name_suffix}")
  ebs_name_base       = "${local.name_prefix}ebs-ec2-${var.account_name}-${var.project_name}${local.name_suffix}"

  # IAM role names are limited to 64 characters (38 when using name_prefix,
  # since AWS appends a 26-character random suffix)
  iam_role_name_full   = coalesce(var.iam_role_name, "${local.name_prefix}role-ec2-${var.account_name}-${var.project_name}${local.name_suffix}")
  iam_role_name        = var.iam_role_use_name_prefix ? null : substr(local.iam_role_name_full, 0, 64)
  iam_role_name_prefix = var.iam_role_use_name_prefix ? "${trimsuffix(substr(local.iam_role_name_full, 0, 37), "-")}-" : null

  # =============================================================================
  # Instance Configuration
  # =============================================================================

  ami = try(coalesce(var.ami, nonsensitive(data.aws_ssm_parameter.ami[0].value)), null)

  # Burstable instance families accept a credit specification
  is_t_instance_type = can(regex("^t(2|3|3a|4g)\\.", var.instance_type))

  iam_instance_profile = local.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile

  vpc_security_group_ids = local.create_security_group ? concat(var.vpc_security_group_ids, [aws_security_group.this[0].id]) : var.vpc_security_group_ids

  instance_id = try(
    aws_instance.this[0].id,
    aws_instance.ignore_ami[0].id,
    null
  )

  instance_availability_zone = try(
    aws_instance.this[0].availability_zone,
    aws_instance.ignore_ami[0].availability_zone,
    null
  )

  # Exposes whichever instance resource was created (on-demand/spot, with or without ignore_ami_changes)
  instance = try(
    aws_instance.this[0],
    aws_instance.ignore_ami[0],
    null
  )

  # =============================================================================
  # Tags
  # =============================================================================

  instance_tags = merge(
    var.tags_common,
    var.instance_tags,
    {
      Name      = local.instance_name
      ManagedBy = "Terraform"
    }
  )

  volume_tags = var.enable_volume_tags ? merge(
    var.tags_common,
    var.volume_tags,
    {
      Name      = local.instance_name
      ManagedBy = "Terraform"
    }
  ) : null
}
