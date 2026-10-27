# =============================================================================
# EC2 Instance
# =============================================================================
# On-demand by default. Spot and capacity-block instances are requested through
# `instance_market_options` on the same resource (no aws_spot_instance_request).

resource "aws_instance" "this" {
  count = local.create && !var.ignore_ami_changes ? 1 : 0

  region = var.region

  ami                         = local.ami
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  monitoring                  = var.monitoring
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = local.iam_instance_profile

  # Security groups only apply when the primary network interface is managed by the instance
  vpc_security_group_ids = var.network_interface == null ? local.vpc_security_group_ids : null
  source_dest_check      = var.network_interface == null ? var.source_dest_check : null

  private_ip            = var.private_ip
  secondary_private_ips = var.secondary_private_ips
  ipv6_address_count    = var.ipv6_address_count
  ipv6_addresses        = var.ipv6_addresses
  enable_primary_ipv6   = var.enable_primary_ipv6

  placement_group            = var.placement_group
  placement_group_id         = var.placement_group_id
  placement_partition_number = var.placement_partition_number
  tenancy                    = var.tenancy
  host_id                    = var.host_id
  host_resource_group_arn    = var.host_resource_group_arn

  disable_api_stop                     = var.disable_api_stop
  disable_api_termination              = var.disable_api_termination
  force_destroy                        = var.force_destroy
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  get_password_data                    = var.get_password_data
  hibernation                          = var.hibernation

  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  # ---------------------------------------------------------------------------
  # Purchasing Options (on-demand / spot / capacity block)
  # ---------------------------------------------------------------------------

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []

    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = instance_market_options.value.spot_options != null ? [instance_market_options.value.spot_options] : []

        content {
          instance_interruption_behavior = spot_options.value.instance_interruption_behavior
          max_price                      = spot_options.value.max_price
          spot_instance_type             = spot_options.value.spot_instance_type
          valid_until                    = spot_options.value.valid_until
        }
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []

    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference

      dynamic "capacity_reservation_target" {
        for_each = capacity_reservation_specification.value.capacity_reservation_target != null ? [capacity_reservation_specification.value.capacity_reservation_target] : []

        content {
          capacity_reservation_id                 = capacity_reservation_target.value.capacity_reservation_id
          capacity_reservation_resource_group_arn = capacity_reservation_target.value.capacity_reservation_resource_group_arn
        }
      }
    }
  }

  dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []

    content {
      id      = launch_template.value.id
      name    = launch_template.value.name
      version = launch_template.value.version
    }
  }

  # ---------------------------------------------------------------------------
  # CPU / Credits / Enclave
  # ---------------------------------------------------------------------------

  dynamic "cpu_options" {
    for_each = var.cpu_options != null ? [var.cpu_options] : []

    content {
      amd_sev_snp           = cpu_options.value.amd_sev_snp
      core_count            = cpu_options.value.core_count
      nested_virtualization = cpu_options.value.nested_virtualization
      threads_per_core      = cpu_options.value.threads_per_core
    }
  }

  credit_specification {
    cpu_credits = local.is_t_instance_type ? var.cpu_credits : null
  }

  enclave_options {
    enabled = var.enclave_options_enabled
  }

  # ---------------------------------------------------------------------------
  # Metadata / Maintenance / Private DNS
  # ---------------------------------------------------------------------------

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []

    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_protocol_ipv6          = metadata_options.value.http_protocol_ipv6
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_tokens                 = metadata_options.value.http_tokens
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
    }
  }

  dynamic "maintenance_options" {
    for_each = var.maintenance_options != null ? [var.maintenance_options] : []

    content {
      auto_recovery = maintenance_options.value.auto_recovery
    }
  }

  dynamic "private_dns_name_options" {
    for_each = var.private_dns_name_options != null ? [var.private_dns_name_options] : []

    content {
      enable_resource_name_dns_a_record    = private_dns_name_options.value.enable_resource_name_dns_a_record
      enable_resource_name_dns_aaaa_record = private_dns_name_options.value.enable_resource_name_dns_aaaa_record
      hostname_type                        = private_dns_name_options.value.hostname_type
    }
  }

  # ---------------------------------------------------------------------------
  # Network Interfaces
  # ---------------------------------------------------------------------------

  dynamic "network_interface" {
    for_each = var.network_interface != null ? var.network_interface : {}

    content {
      network_interface_id  = network_interface.value.network_interface_id
      device_index          = coalesce(network_interface.value.device_index, network_interface.key)
      network_card_index    = network_interface.value.network_card_index
      delete_on_termination = network_interface.value.delete_on_termination
    }
  }

  # ---------------------------------------------------------------------------
  # Block Devices
  # ---------------------------------------------------------------------------

  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []

    content {
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      iops                  = root_block_device.value.iops
      kms_key_id            = root_block_device.value.kms_key_id
      throughput            = root_block_device.value.throughput
      volume_size           = root_block_device.value.size
      volume_type           = root_block_device.value.type
      tags                  = root_block_device.value.tags
    }
  }

  # Inline EBS devices are created/destroyed with the instance. Prefer `ebs_volumes`
  # (standalone volumes + attachments) for data that must outlive the instance.
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device != null ? var.ebs_block_device : {}

    content {
      device_name           = coalesce(ebs_block_device.value.device_name, ebs_block_device.key)
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
      iops                  = ebs_block_device.value.iops
      kms_key_id            = ebs_block_device.value.kms_key_id
      snapshot_id           = ebs_block_device.value.snapshot_id
      throughput            = ebs_block_device.value.throughput
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.type
      tags                  = ebs_block_device.value.tags
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device != null ? var.ephemeral_block_device : {}

    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = ephemeral_block_device.value.no_device
      virtual_name = ephemeral_block_device.value.virtual_name
    }
  }

  volume_tags = local.volume_tags

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = local.instance_tags
}

# =============================================================================
# EC2 Instance - Ignore AMI Changes
# =============================================================================
# Same configuration as above, but AMI updates (e.g. a new image published to
# the SSM parameter) do not trigger a replacement. Toggling
# `ignore_ami_changes` replaces the instance.

resource "aws_instance" "ignore_ami" {
  count = local.create && var.ignore_ami_changes ? 1 : 0

  region = var.region

  ami                         = local.ami
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  monitoring                  = var.monitoring
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = local.iam_instance_profile

  # Security groups only apply when the primary network interface is managed by the instance
  vpc_security_group_ids = var.network_interface == null ? local.vpc_security_group_ids : null
  source_dest_check      = var.network_interface == null ? var.source_dest_check : null

  private_ip            = var.private_ip
  secondary_private_ips = var.secondary_private_ips
  ipv6_address_count    = var.ipv6_address_count
  ipv6_addresses        = var.ipv6_addresses
  enable_primary_ipv6   = var.enable_primary_ipv6

  placement_group            = var.placement_group
  placement_group_id         = var.placement_group_id
  placement_partition_number = var.placement_partition_number
  tenancy                    = var.tenancy
  host_id                    = var.host_id
  host_resource_group_arn    = var.host_resource_group_arn

  disable_api_stop                     = var.disable_api_stop
  disable_api_termination              = var.disable_api_termination
  force_destroy                        = var.force_destroy
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  get_password_data                    = var.get_password_data
  hibernation                          = var.hibernation

  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  # ---------------------------------------------------------------------------
  # Purchasing Options (on-demand / spot / capacity block)
  # ---------------------------------------------------------------------------

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []

    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = instance_market_options.value.spot_options != null ? [instance_market_options.value.spot_options] : []

        content {
          instance_interruption_behavior = spot_options.value.instance_interruption_behavior
          max_price                      = spot_options.value.max_price
          spot_instance_type             = spot_options.value.spot_instance_type
          valid_until                    = spot_options.value.valid_until
        }
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []

    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference

      dynamic "capacity_reservation_target" {
        for_each = capacity_reservation_specification.value.capacity_reservation_target != null ? [capacity_reservation_specification.value.capacity_reservation_target] : []

        content {
          capacity_reservation_id                 = capacity_reservation_target.value.capacity_reservation_id
          capacity_reservation_resource_group_arn = capacity_reservation_target.value.capacity_reservation_resource_group_arn
        }
      }
    }
  }

  dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []

    content {
      id      = launch_template.value.id
      name    = launch_template.value.name
      version = launch_template.value.version
    }
  }

  # ---------------------------------------------------------------------------
  # CPU / Credits / Enclave
  # ---------------------------------------------------------------------------

  dynamic "cpu_options" {
    for_each = var.cpu_options != null ? [var.cpu_options] : []

    content {
      amd_sev_snp           = cpu_options.value.amd_sev_snp
      core_count            = cpu_options.value.core_count
      nested_virtualization = cpu_options.value.nested_virtualization
      threads_per_core      = cpu_options.value.threads_per_core
    }
  }

  credit_specification {
    cpu_credits = local.is_t_instance_type ? var.cpu_credits : null
  }

  enclave_options {
    enabled = var.enclave_options_enabled
  }

  # ---------------------------------------------------------------------------
  # Metadata / Maintenance / Private DNS
  # ---------------------------------------------------------------------------

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []

    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_protocol_ipv6          = metadata_options.value.http_protocol_ipv6
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_tokens                 = metadata_options.value.http_tokens
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
    }
  }

  dynamic "maintenance_options" {
    for_each = var.maintenance_options != null ? [var.maintenance_options] : []

    content {
      auto_recovery = maintenance_options.value.auto_recovery
    }
  }

  dynamic "private_dns_name_options" {
    for_each = var.private_dns_name_options != null ? [var.private_dns_name_options] : []

    content {
      enable_resource_name_dns_a_record    = private_dns_name_options.value.enable_resource_name_dns_a_record
      enable_resource_name_dns_aaaa_record = private_dns_name_options.value.enable_resource_name_dns_aaaa_record
      hostname_type                        = private_dns_name_options.value.hostname_type
    }
  }

  # ---------------------------------------------------------------------------
  # Network Interfaces
  # ---------------------------------------------------------------------------

  dynamic "network_interface" {
    for_each = var.network_interface != null ? var.network_interface : {}

    content {
      network_interface_id  = network_interface.value.network_interface_id
      device_index          = coalesce(network_interface.value.device_index, network_interface.key)
      network_card_index    = network_interface.value.network_card_index
      delete_on_termination = network_interface.value.delete_on_termination
    }
  }

  # ---------------------------------------------------------------------------
  # Block Devices
  # ---------------------------------------------------------------------------

  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []

    content {
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      iops                  = root_block_device.value.iops
      kms_key_id            = root_block_device.value.kms_key_id
      throughput            = root_block_device.value.throughput
      volume_size           = root_block_device.value.size
      volume_type           = root_block_device.value.type
      tags                  = root_block_device.value.tags
    }
  }

  # Inline EBS devices are created/destroyed with the instance. Prefer `ebs_volumes`
  # (standalone volumes + attachments) for data that must outlive the instance.
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device != null ? var.ebs_block_device : {}

    content {
      device_name           = coalesce(ebs_block_device.value.device_name, ebs_block_device.key)
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
      iops                  = ebs_block_device.value.iops
      kms_key_id            = ebs_block_device.value.kms_key_id
      snapshot_id           = ebs_block_device.value.snapshot_id
      throughput            = ebs_block_device.value.throughput
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.type
      tags                  = ebs_block_device.value.tags
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device != null ? var.ephemeral_block_device : {}

    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = ephemeral_block_device.value.no_device
      virtual_name = ephemeral_block_device.value.virtual_name
    }
  }

  volume_tags = local.volume_tags

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = local.instance_tags

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}
