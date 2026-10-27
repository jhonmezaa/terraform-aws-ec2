# =============================================================================
# Elastic IP
# =============================================================================

resource "aws_eip" "this" {
  count = local.create_eip ? 1 : 0

  region = var.region

  domain   = var.eip_domain
  instance = local.instance_id

  tags = merge(
    var.tags_common,
    var.eip_tags,
    {
      Name      = local.eip_name
      ManagedBy = "Terraform"
    }
  )
}
