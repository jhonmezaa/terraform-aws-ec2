# =============================================================================
# Additional EBS Volumes
# =============================================================================

resource "aws_ebs_volume" "this" {
  for_each = local.create && var.ebs_volumes != null ? var.ebs_volumes : {}

  region = var.region

  availability_zone          = local.instance_availability_zone
  size                       = each.value.size
  type                       = each.value.type
  iops                       = each.value.iops
  throughput                 = each.value.throughput
  encrypted                  = each.value.encrypted
  kms_key_id                 = each.value.kms_key_id
  snapshot_id                = each.value.snapshot_id
  multi_attach_enabled       = each.value.multi_attach_enabled
  outpost_arn                = each.value.outpost_arn
  final_snapshot             = each.value.final_snapshot
  volume_initialization_rate = each.value.volume_initialization_rate

  tags = merge(
    var.tags_common,
    var.volume_tags,
    each.value.tags,
    {
      Name      = coalesce(each.value.name, "${local.ebs_name_base}-${each.key}")
      ManagedBy = "Terraform"
    }
  )
}

# =============================================================================
# Volume Attachments
# =============================================================================

resource "aws_volume_attachment" "this" {
  for_each = local.create && var.ebs_volumes != null ? var.ebs_volumes : {}

  region = var.region

  device_name                    = coalesce(each.value.device_name, each.key)
  instance_id                    = local.instance_id
  volume_id                      = aws_ebs_volume.this[each.key].id
  force_detach                   = each.value.force_detach
  skip_destroy                   = each.value.skip_destroy
  stop_instance_before_detaching = each.value.stop_instance_before_detaching
}
