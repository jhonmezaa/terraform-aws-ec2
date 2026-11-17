# Changelog

All notable changes to this project will be documented in this file.

## [v1.0.2] - 2026-11-17

### Fixed

- Raise the minimum AWS provider version of the module to `>= 6.33` (was `>= 6.0`): `cpu_options.nested_virtualization` needs 6.33 and `force_destroy` / `placement_group_id` on `aws_instance` need newer releases than 6.0, so `terraform validate` failed with any provider below 6.33. Examples now use `~> 6.33`
- `data.aws_ssm_parameter.ami` no longer uses `var.ami == null` in `count`: an `ami` only known after apply (e.g. from another resource) caused `Invalid count argument`. The parameter is now always read when `create = true`; an explicit `ami` still takes precedence
- Security group name no longer starts with `sg-` when `use_region_prefix = false` (AWS rejects it): it is now `ec2-sg-{account_name}-{project_name}[-{name_suffix}]`. `security_group_name` values starting with `sg-` are rejected by validation
- `Name` tag of the IAM role and instance profile now matches the real name when it is truncated to 64 characters
- README: `source` uses `github.com/jhonmezaa/terraform-aws-ec2//ec2?ref=<tag>` and requirements show `aws >= 6.33`

### Upgrade notes

- The AMI SSM parameter is read even when `ami` is set, so the caller needs `ssm:GetParameter` on it (same behaviour as the official module)
- Requires AWS provider `>= 6.33`. Lower versions never worked with this module
- No resource is replaced: security group names only change for `use_region_prefix = false`, which could not be applied before

## [v1.0.1] - 2026-10-27

### Changed

- Use minimum-only version constraints in the module (`ec2/`): AWS provider `~> 6.0` -> `>= 6.0`, so callers are not blocked from newer major provider versions
- Set module `required_version` to `>= 1.3` (was `~> 1.0`): the minimum real Terraform version, since variables use `optional()` object attributes with defaults (Terraform 1.3+)
- Examples (root modules) keep pessimistic constraints: `required_version` `~> 1.3`, AWS provider `~> 6.0`
- Update requirements tables in the root README and example READMEs

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
