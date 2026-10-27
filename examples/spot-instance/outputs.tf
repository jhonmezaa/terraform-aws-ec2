output "instance_id" {
  description = "ID of the Spot instance."
  value       = module.ec2_spot.id
}

output "instance_lifecycle" {
  description = "Lifecycle of the instance (spot)."
  value       = module.ec2_spot.instance_lifecycle
}

output "spot_instance_request_id" {
  description = "ID of the Spot request backing the instance."
  value       = module.ec2_spot.spot_instance_request_id
}

output "private_ip" {
  description = "Private IP of the instance."
  value       = module.ec2_spot.private_ip
}
