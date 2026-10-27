# =============================================================================
# Instance
# =============================================================================

output "id" {
  description = "ID of the instance."
  value       = local.instance_id
}

output "arn" {
  description = "ARN of the instance."
  value       = try(local.instance.arn, null)
}

output "name" {
  description = "Name of the instance."
  value       = local.create ? local.instance_name : null
}

output "instance_state" {
  description = "State of the instance."
  value       = try(local.instance.instance_state, null)
}

output "instance_lifecycle" {
  description = "Lifecycle of the instance (`spot` or `capacity-block` when not on-demand)."
  value       = try(local.instance.instance_lifecycle, null)
}

output "spot_instance_request_id" {
  description = "ID of the Spot request backing the instance, if any."
  value       = try(local.instance.spot_instance_request_id, null)
}

output "ami" {
  description = "AMI ID used to create the instance."
  value       = try(local.instance.ami, null)
}

output "availability_zone" {
  description = "Availability zone of the instance."
  value       = local.instance_availability_zone
}

output "capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance."
  value       = try(local.instance.capacity_reservation_specification, null)
}

output "outpost_arn" {
  description = "ARN of the Outpost the instance is assigned to."
  value       = try(local.instance.outpost_arn, null)
}

output "password_data" {
  description = "Base64-encoded encrypted Windows password data. Only available when `get_password_data = true`."
  value       = try(local.instance.password_data, null)
  sensitive   = true
}

output "primary_network_interface_id" {
  description = "ID of the primary network interface."
  value       = try(local.instance.primary_network_interface_id, null)
}

output "private_dns" {
  description = "Private DNS name of the instance."
  value       = try(local.instance.private_dns, null)
}

output "public_dns" {
  description = "Public DNS name of the instance."
  value       = try(local.instance.public_dns, null)
}

output "private_ip" {
  description = "Private IP address of the instance."
  value       = try(local.instance.private_ip, null)
}

output "public_ip" {
  description = "Public IP address of the instance (the Elastic IP when created)."
  value       = try(aws_eip.this[0].public_ip, local.instance.public_ip, null)
}

output "ipv6_addresses" {
  description = "IPv6 addresses assigned to the instance."
  value       = try(local.instance.ipv6_addresses, [])
}

output "tags_all" {
  description = "Tags assigned to the instance, including provider default_tags."
  value       = try(local.instance.tags_all, {})
}

# =============================================================================
# Block Devices
# =============================================================================

output "root_block_device" {
  description = "Root block device information."
  value       = try(local.instance.root_block_device, null)
}

output "ebs_block_device" {
  description = "Inline EBS block device information."
  value       = try(local.instance.ebs_block_device, null)
}

output "ephemeral_block_device" {
  description = "Ephemeral block device information."
  value       = try(local.instance.ephemeral_block_device, null)
}

output "ebs_volumes" {
  description = "Map of additional EBS volumes created and their attributes."
  value       = aws_ebs_volume.this
}

output "volume_attachments" {
  description = "Map of EBS volume attachments."
  value       = aws_volume_attachment.this
}

# =============================================================================
# IAM Role / Instance Profile
# =============================================================================

output "iam_role_name" {
  description = "Name of the IAM role."
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_arn" {
  description = "ARN of the IAM role."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_unique_id" {
  description = "Unique ID of the IAM role."
  value       = try(aws_iam_role.this[0].unique_id, null)
}

output "iam_instance_profile_name" {
  description = "Name of the instance profile."
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "iam_instance_profile_arn" {
  description = "ARN of the instance profile."
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "iam_instance_profile_id" {
  description = "ID of the instance profile."
  value       = try(aws_iam_instance_profile.this[0].id, null)
}

output "iam_instance_profile_unique" {
  description = "Unique ID of the instance profile."
  value       = try(aws_iam_instance_profile.this[0].unique_id, null)
}

# =============================================================================
# Security Group
# =============================================================================

output "security_group_id" {
  description = "ID of the managed security group."
  value       = try(aws_security_group.this[0].id, null)
}

output "security_group_arn" {
  description = "ARN of the managed security group."
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_name" {
  description = "Name of the managed security group."
  value       = try(aws_security_group.this[0].name, null)
}

# =============================================================================
# Elastic IP
# =============================================================================

output "eip_id" {
  description = "Allocation ID of the Elastic IP."
  value       = try(aws_eip.this[0].id, null)
}

output "eip_public_ip" {
  description = "Public IP of the Elastic IP."
  value       = try(aws_eip.this[0].public_ip, null)
}

output "eip_public_dns" {
  description = "Public DNS of the Elastic IP."
  value       = try(aws_eip.this[0].public_dns, null)
}
