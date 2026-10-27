output "instance_id" {
  description = "ID of the instance."
  value       = module.ec2.id
}

output "instance_name" {
  description = "Name of the instance."
  value       = module.ec2.name
}

output "private_ip" {
  description = "Private IP of the instance."
  value       = module.ec2.private_ip
}

output "security_group_id" {
  description = "Managed security group ID."
  value       = module.ec2.security_group_id
}
