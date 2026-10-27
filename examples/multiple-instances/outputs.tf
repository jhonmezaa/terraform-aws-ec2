output "instance_ids" {
  description = "Map of instance IDs by key."
  value       = { for k, v in module.ec2 : k => v.id }
}

output "instance_names" {
  description = "Map of instance names by key."
  value       = { for k, v in module.ec2 : k => v.name }
}

output "private_ips" {
  description = "Map of private IPs by key."
  value       = { for k, v in module.ec2 : k => v.private_ip }
}
