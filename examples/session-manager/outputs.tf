output "instance_id" {
  description = "ID of the instance (target for `aws ssm start-session`)."
  value       = module.ec2.id
}

output "iam_role_name" {
  description = "Name of the IAM role attached to the instance."
  value       = module.ec2.iam_role_name
}

output "iam_instance_profile_arn" {
  description = "ARN of the instance profile."
  value       = module.ec2.iam_instance_profile_arn
}

output "vpc_endpoint_ids" {
  description = "IDs of the SSM interface endpoints."
  value       = { for k, v in aws_vpc_endpoint.ssm : k => v.id }
}
