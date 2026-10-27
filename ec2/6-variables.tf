# =============================================================================
# General
# =============================================================================

variable "create" {
  description = "Controls if resources should be created (affects all resources)."
  type        = bool
  default     = true
}

variable "account_name" {
  description = "Account name for resource naming."
  type        = string

  validation {
    condition     = length(var.account_name) > 0 && length(var.account_name) <= 32
    error_message = "account_name debe tener entre 1 y 32 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.account_name))
    error_message = "account_name solo puede contener letras minúsculas, números y guiones."
  }
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "project_name debe tener entre 1 y 32 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name solo puede contener letras minúsculas, números y guiones."
  }
}

variable "region_prefix" {
  description = "Region prefix for naming. If not provided, will be derived from current region."
  type        = string
  default     = null
}

variable "use_region_prefix" {
  description = "Whether to include the region prefix in resource names. When false, names omit the region prefix."
  type        = bool
  default     = true
}

variable "name_suffix" {
  description = "Optional suffix appended to every generated name (e.g. the for_each key when creating several instances). Ignored for names set explicitly."
  type        = string
  default     = null

  validation {
    condition     = var.name_suffix == null || can(regex("^[a-z0-9-]+$", var.name_suffix))
    error_message = "name_suffix solo puede contener letras minúsculas, números y guiones."
  }
}

variable "region" {
  description = "Region where the resources will be managed. Defaults to the region set in the provider configuration."
  type        = string
  default     = null
}

variable "tags_common" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Instance
# =============================================================================

variable "name" {
  description = "Instance name. If null, it is generated as {region_prefix}-ec2-{account_name}-{project_name}[-{name_suffix}]."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The type of instance to start."
  type        = string
  default     = "t3.micro"
}

variable "ami" {
  description = "ID of the AMI to use for the instance. If null, the AMI is resolved from `ami_ssm_parameter`."
  type        = string
  default     = null
}

variable "ami_ssm_parameter" {
  description = "SSM parameter name holding the AMI ID. Used only when `ami` is null."
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "ignore_ami_changes" {
  description = "Whether AMI ID changes should be ignored by Terraform. Changing this value replaces the instance."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "AZ to start the instance in."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The VPC subnet ID to launch in. Required when `create_security_group = true` (used to resolve the VPC when `vpc_id` is null)."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance in a VPC."
  type        = bool
  default     = null
}

variable "key_name" {
  description = "Key pair name to use for the instance."
  type        = string
  default     = null
}

variable "monitoring" {
  description = "If true, the instance will have detailed monitoring enabled."
  type        = bool
  default     = null
}

variable "ebs_optimized" {
  description = "If true, the instance will be EBS-optimized."
  type        = bool
  default     = null
}

variable "iam_instance_profile" {
  description = "Name of an existing IAM instance profile. Ignored when `create_iam_instance_profile = true`."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of existing security group IDs to associate (the managed security group is appended when created)."
  type        = list(string)
  default     = []
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Disable for NAT or VPN instances."
  type        = bool
  default     = null
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  type        = string
  default     = null
}

variable "secondary_private_ips" {
  description = "List of secondary private IPv4 addresses to assign to the primary network interface (eth0)."
  type        = list(string)
  default     = null
}

variable "ipv6_address_count" {
  description = "Number of IPv6 addresses to associate with the primary network interface."
  type        = number
  default     = null
}

variable "ipv6_addresses" {
  description = "List of IPv6 addresses from the subnet range to associate with the primary network interface."
  type        = list(string)
  default     = null
}

variable "enable_primary_ipv6" {
  description = "Whether to assign a primary IPv6 Global Unicast Address (GUA) when launched in a dual-stack or IPv6-only subnet."
  type        = bool
  default     = null
}

variable "network_interface" {
  description = "Existing network interfaces to attach at boot time. When set, the managed security group is not created and `vpc_security_group_ids` is ignored."
  type = map(object({
    network_interface_id  = string
    device_index          = optional(number) # Falls back to the map key
    network_card_index    = optional(number)
    delete_on_termination = optional(bool)
  }))
  default = null
}

variable "placement_group" {
  description = "Placement group name to start the instance in. Conflicts with `placement_group_id`."
  type        = string
  default     = null
}

variable "placement_group_id" {
  description = "Placement group ID to start the instance in. Conflicts with `placement_group`."
  type        = string
  default     = null
}

variable "placement_partition_number" {
  description = "Partition number within a placement group using the `partition` strategy."
  type        = number
  default     = null
}

variable "tenancy" {
  description = "Tenancy of the instance: default, dedicated or host."
  type        = string
  default     = null

  validation {
    condition     = var.tenancy == null || contains(["default", "dedicated", "host"], coalesce(var.tenancy, "default"))
    error_message = "tenancy debe ser default, dedicated o host."
  }
}

variable "host_id" {
  description = "ID of a dedicated host to launch the instance on."
  type        = string
  default     = null
}

variable "host_resource_group_arn" {
  description = "ARN of the host resource group in which to launch the instance. Omit `tenancy` or set it to `host` when used."
  type        = string
  default     = null
}

variable "disable_api_stop" {
  description = "If true, enables EC2 instance stop protection."
  type        = bool
  default     = null
}

variable "disable_api_termination" {
  description = "If true, enables EC2 instance termination protection."
  type        = bool
  default     = null
}

variable "force_destroy" {
  description = "Destroy the instance even if `disable_api_termination` or `disable_api_stop` is enabled. Requires a successful apply before the destroy to take effect."
  type        = bool
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance: stop or terminate."
  type        = string
  default     = null

  validation {
    condition     = var.instance_initiated_shutdown_behavior == null || contains(["stop", "terminate"], coalesce(var.instance_initiated_shutdown_behavior, "stop"))
    error_message = "instance_initiated_shutdown_behavior debe ser stop o terminate."
  }
}

variable "get_password_data" {
  description = "If true, wait for Windows password data to become available and retrieve it."
  type        = bool
  default     = null
}

variable "hibernation" {
  description = "If true, the instance supports hibernation (requires an encrypted root volume large enough to hold RAM)."
  type        = bool
  default     = null
}

variable "enclave_options_enabled" {
  description = "Whether Nitro Enclaves are enabled on the instance. Cannot be combined with hibernation."
  type        = bool
  default     = null
}

variable "user_data" {
  description = "User data to provide when launching the instance. Use `user_data_base64` for gzip-compressed or binary data."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data. Use instead of `user_data` when the content is not valid UTF-8."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When true, changes to `user_data` or `user_data_base64` trigger a destroy and recreate of the instance."
  type        = bool
  default     = null
}

variable "instance_market_options" {
  description = "Purchasing option for the instance. Set `market_type = \"spot\"` to launch a Spot instance."
  type = object({
    market_type = optional(string, "spot")
    spot_options = optional(object({
      instance_interruption_behavior = optional(string)
      max_price                      = optional(string)
      spot_instance_type             = optional(string)
      valid_until                    = optional(string)
    }))
  })
  default = null

  validation {
    condition     = var.instance_market_options == null || contains(["spot", "capacity-block"], try(var.instance_market_options.market_type, "spot"))
    error_message = "instance_market_options.market_type debe ser spot o capacity-block."
  }
}

variable "capacity_reservation_specification" {
  description = "Capacity Reservation targeting option for the instance."
  type = object({
    capacity_reservation_preference = optional(string)
    capacity_reservation_target = optional(object({
      capacity_reservation_id                 = optional(string)
      capacity_reservation_resource_group_arn = optional(string)
    }))
  })
  default = null
}

variable "launch_template" {
  description = "Existing launch template used to configure the instance. Arguments set on this module override the template values."
  type = object({
    id      = optional(string)
    name    = optional(string)
    version = optional(string)
  })
  default = null
}

variable "cpu_options" {
  description = "CPU options applied at launch time."
  type = object({
    amd_sev_snp           = optional(string)
    core_count            = optional(number)
    nested_virtualization = optional(string)
    threads_per_core      = optional(number)
  })
  default = null
}

variable "cpu_credits" {
  description = "Credit option for CPU usage (standard or unlimited). Only applied to burstable (t2/t3/t3a/t4g) instance types."
  type        = string
  default     = null

  validation {
    condition     = var.cpu_credits == null || contains(["standard", "unlimited"], coalesce(var.cpu_credits, "standard"))
    error_message = "cpu_credits debe ser standard o unlimited."
  }
}

variable "metadata_options" {
  description = "Instance metadata service options. IMDSv2 (`http_tokens = \"required\"`) is enforced by default."
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_protocol_ipv6          = optional(string)
    http_put_response_hop_limit = optional(number, 1)
    http_tokens                 = optional(string, "required")
    instance_metadata_tags      = optional(string)
  })
  default = {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
}

variable "maintenance_options" {
  description = "Maintenance options for the instance."
  type = object({
    auto_recovery = optional(string)
  })
  default = null
}

variable "private_dns_name_options" {
  description = "Private DNS name options for the instance."
  type = object({
    enable_resource_name_dns_a_record    = optional(bool)
    enable_resource_name_dns_aaaa_record = optional(bool)
    hostname_type                        = optional(string)
  })
  default = null
}

variable "timeouts" {
  description = "Timeouts for creating, updating and deleting the instance."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "instance_tags" {
  description = "Additional tags for the instance."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Block Devices
# =============================================================================

variable "root_block_device" {
  description = "Root block device configuration."
  type = object({
    delete_on_termination = optional(bool)
    encrypted             = optional(bool)
    iops                  = optional(number)
    kms_key_id            = optional(string)
    size                  = optional(number)
    throughput            = optional(number)
    type                  = optional(string)
    tags                  = optional(map(string))
  })
  default = null
}

variable "ebs_block_device" {
  description = "Inline EBS block devices created with the instance (map key used as device name when `device_name` is not set). Do not mix with `ebs_volumes` on the same device."
  type = map(object({
    device_name           = optional(string)
    delete_on_termination = optional(bool)
    encrypted             = optional(bool)
    iops                  = optional(number)
    kms_key_id            = optional(string)
    snapshot_id           = optional(string)
    size                  = optional(number)
    throughput            = optional(number)
    type                  = optional(string)
    tags                  = optional(map(string))
  }))
  default = null
}

variable "ephemeral_block_device" {
  description = "Instance store (ephemeral) volumes."
  type = map(object({
    device_name  = string
    no_device    = optional(bool)
    virtual_name = optional(string)
  }))
  default = null
}

variable "enable_volume_tags" {
  description = "Whether to apply `volume_tags` to the volumes created at launch. Conflicts with `root_block_device.tags` and `ebs_block_device.tags`."
  type        = bool
  default     = true
}

variable "volume_tags" {
  description = "Additional tags for the volumes created at launch and for `ebs_volumes`."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Additional EBS Volumes
# =============================================================================

variable "ebs_volumes" {
  description = "Standalone EBS volumes attached to the instance. The map key is used in the volume name and, unless `device_name` is set, as the device name."
  type = map(object({
    name                       = optional(string)
    size                       = optional(number)
    type                       = optional(string, "gp3")
    iops                       = optional(number)
    throughput                 = optional(number)
    encrypted                  = optional(bool, true)
    kms_key_id                 = optional(string)
    snapshot_id                = optional(string)
    multi_attach_enabled       = optional(bool)
    outpost_arn                = optional(string)
    final_snapshot             = optional(bool)
    volume_initialization_rate = optional(number)
    tags                       = optional(map(string), {})
    # Attachment
    device_name                    = optional(string)
    force_detach                   = optional(bool)
    skip_destroy                   = optional(bool)
    stop_instance_before_detaching = optional(bool)
  }))
  default = null
}

# =============================================================================
# IAM Role / Instance Profile
# =============================================================================

variable "create_iam_instance_profile" {
  description = "Whether to create an IAM role and instance profile for the instance."
  type        = bool
  default     = false
}

variable "iam_role_name" {
  description = "IAM role (and instance profile) name. If null, it is generated as {region_prefix}-role-ec2-{account_name}-{project_name}[-{name_suffix}] and truncated to 64 characters."
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Whether to use the IAM role name as a prefix (truncated to 38 characters, AWS appends a random suffix)."
  type        = bool
  default     = false
}

variable "iam_role_path" {
  description = "IAM role and instance profile path."
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the IAM role."
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy used as permissions boundary for the IAM role."
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Map of policy ARNs to attach to the IAM role."
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "Additional tags for the IAM role and instance profile."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Security Group
# =============================================================================

variable "create_security_group" {
  description = "Whether to create a managed security group. Not created when `network_interface` is set."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Security group name. If null, it is generated as {region_prefix}-sg-ec2-{account_name}-{project_name}[-{name_suffix}]."
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Whether to use the security group name as a prefix."
  type        = bool
  default     = false
}

variable "security_group_description" {
  description = "Description of the security group."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID for the managed security group. If null, it is resolved from `subnet_id`."
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Ingress rules for the managed security group. `from_port`/`to_port` are ignored when `ip_protocol = \"-1\"`."
  type = map(object({
    description                  = optional(string)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
  }))
  default = null
}

variable "security_group_egress_rules" {
  description = "Egress rules for the managed security group. Defaults to allow all IPv4/IPv6 outbound traffic."
  type = map(object({
    description                  = optional(string)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
  }))
  default = {
    ipv4_default = {
      description = "Allow all IPv4 outbound traffic"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
    ipv6_default = {
      description = "Allow all IPv6 outbound traffic"
      cidr_ipv6   = "::/0"
      ip_protocol = "-1"
    }
  }
}

variable "security_group_tags" {
  description = "Additional tags for the security group and its rules."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Elastic IP
# =============================================================================

variable "create_eip" {
  description = "Whether to create an Elastic IP and associate it with the instance."
  type        = bool
  default     = false
}

variable "eip_name" {
  description = "Elastic IP Name tag. If null, it is generated as {region_prefix}-eip-ec2-{account_name}-{project_name}[-{name_suffix}]."
  type        = string
  default     = null
}

variable "eip_domain" {
  description = "Indicates if the EIP is for use in a VPC."
  type        = string
  default     = "vpc"
}

variable "eip_tags" {
  description = "Additional tags for the Elastic IP."
  type        = map(string)
  default     = {}
}
