# =============================================================================
# IAM Role
# =============================================================================

data "aws_iam_policy_document" "assume_role" {
  count = local.create_iam_instance_profile ? 1 : 0

  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create_iam_instance_profile ? 1 : 0

  name                  = local.iam_role_name
  name_prefix           = local.iam_role_name_prefix
  path                  = var.iam_role_path
  description           = coalesce(var.iam_role_description, "IAM role for EC2 instance ${local.instance_name}")
  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(
    var.tags_common,
    var.iam_role_tags,
    {
      Name      = local.iam_role_name_full
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in var.iam_role_policies : k => v if local.create_iam_instance_profile }

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

# =============================================================================
# Instance Profile
# =============================================================================

resource "aws_iam_instance_profile" "this" {
  count = local.create_iam_instance_profile ? 1 : 0

  name        = local.iam_role_name
  name_prefix = local.iam_role_name_prefix
  path        = var.iam_role_path
  role        = aws_iam_role.this[0].name

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags_common,
    var.iam_role_tags,
    {
      Name      = local.iam_role_name_full
      ManagedBy = "Terraform"
    }
  )
}
