# Changelog

All notable changes to this project will be documented in this file.

## [v1.0.0] - 2026-10-27

### Added

- Initial release of terraform-aws-ec2 module
- Single EC2 instance per module call (`for_each` in the caller for multiple instances)
- On-demand, Spot and capacity-block instances via `instance_market_options`
- AMI resolved from SSM parameter by default (Amazon Linux 2023), with optional `ignore_ami_changes`
- Optional reference to an existing launch template
- Root, inline EBS and ephemeral block devices
- Standalone EBS volumes with volume attachments
- Optional IAM role and instance profile with policy attachments and permissions boundary
- Optional managed security group with `aws_vpc_security_group_ingress_rule`/`egress_rule` and auto-null ports for `ip_protocol = "-1"`
- Optional Elastic IP
- IMDSv2 required by default
- CPU options, credit specification, capacity reservation, maintenance options, private DNS name options, Nitro Enclaves and hibernation
- `user_data`, `user_data_base64` and `user_data_replace_on_change`
- Instance timeouts
- Standard naming convention: `{region_prefix}-ec2-{account_name}-{project_name}` (plus `sg-ec2`, `role-ec2`, `eip-ec2`, `ebs-ec2` variants) with optional `name_suffix`
- Region prefix auto-detection from AWS region
- 5 examples: basic, complete, spot-instance, session-manager, multiple-instances
