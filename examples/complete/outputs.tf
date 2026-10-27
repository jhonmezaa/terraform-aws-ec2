output "instance_id" {
  description = "ID of the instance."
  value       = module.ec2.id
}

output "instance_arn" {
  description = "ARN of the instance."
  value       = module.ec2.arn
}

output "ami" {
  description = "AMI used by the instance."
  value       = module.ec2.ami
}

output "public_ip" {
  description = "Public IP (Elastic IP) of the instance."
  value       = module.ec2.public_ip
}

output "private_dns" {
  description = "Private DNS name of the instance."
  value       = module.ec2.private_dns
}

output "root_block_device" {
  description = "Root block device information."
  value       = module.ec2.root_block_device
}

output "ebs_volumes" {
  description = "Additional EBS volume IDs."
  value       = { for k, v in module.ec2.ebs_volumes : k => v.id }
}

output "iam_role_arn" {
  description = "ARN of the IAM role."
  value       = module.ec2.iam_role_arn
}

output "iam_instance_profile_arn" {
  description = "ARN of the instance profile."
  value       = module.ec2.iam_instance_profile_arn
}

output "security_group_id" {
  description = "Managed security group ID."
  value       = module.ec2.security_group_id
}

output "eip_id" {
  description = "Allocation ID of the Elastic IP."
  value       = module.ec2.eip_id
}
