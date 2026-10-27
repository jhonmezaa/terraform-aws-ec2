# =============================================================================
# Managed Security Group
# =============================================================================

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description != null ? var.security_group_description : "Security group for ${local.instance_name}"
  vpc_id      = coalesce(var.vpc_id, data.aws_subnet.this[0].vpc_id)

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags_common,
    var.security_group_tags,
    {
      Name      = local.security_group_name
      ManagedBy = "Terraform"
    }
  )
}

# =============================================================================
# Ingress Rules
# =============================================================================

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for k, v in(var.security_group_ingress_rules != null ? var.security_group_ingress_rules : {}) : k => v
    if local.create_security_group
  }

  region = var.region

  security_group_id = aws_security_group.this[0].id

  description                  = each.value.description
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  from_port                    = each.value.ip_protocol == "-1" ? null : try(coalesce(each.value.from_port, each.value.to_port), null)
  to_port                      = each.value.ip_protocol == "-1" ? null : try(coalesce(each.value.to_port, each.value.from_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id

  tags = merge(
    var.tags_common,
    var.security_group_tags,
    each.value.tags,
    {
      Name      = "${local.security_group_name}-ingress-${each.key}"
      ManagedBy = "Terraform"
    }
  )
}

# =============================================================================
# Egress Rules
# =============================================================================

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = {
    for k, v in(var.security_group_egress_rules != null ? var.security_group_egress_rules : {}) : k => v
    if local.create_security_group
  }

  region = var.region

  security_group_id = aws_security_group.this[0].id

  description                  = each.value.description
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  from_port                    = each.value.ip_protocol == "-1" ? null : try(coalesce(each.value.from_port, each.value.to_port), null)
  to_port                      = each.value.ip_protocol == "-1" ? null : try(coalesce(each.value.to_port, each.value.from_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id

  tags = merge(
    var.tags_common,
    var.security_group_tags,
    each.value.tags,
    {
      Name      = "${local.security_group_name}-egress-${each.key}"
      ManagedBy = "Terraform"
    }
  )
}
