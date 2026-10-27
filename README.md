# terraform-aws-ec2

Terraform module to create a single AWS EC2 instance (on-demand or Spot) with optional IAM instance profile, managed security group, Elastic IP and additional EBS volumes.

## Features

### Instance

- **On-demand or Spot** - Spot and capacity-block instances through `instance_market_options` on the same `aws_instance` resource
- **AMI from SSM** - latest Amazon Linux 2023 resolved from a public SSM parameter by default, or an explicit `ami`
- **Ignore AMI changes** - optional `ignore_ami_changes` so new AMIs do not replace running instances
- **Launch template** - reference an existing launch template; module arguments override template values
- **CPU options** - core count, threads per core, AMD SEV-SNP, nested virtualization
- **Credit specification** - `standard` / `unlimited` (applied only to burstable t2/t3/t3a/t4g types)
- **Capacity reservations** - preference and target (reservation ID or resource group)
- **Hibernation** and **Nitro Enclaves**
- **Placement** - placement group, partition number, tenancy, dedicated host / host resource group
- **User data** - `user_data`, `user_data_base64` and `user_data_replace_on_change`
- **Timeouts** - create, update and delete

### Security

- **IMDSv2 required by default** (`http_tokens = "required"`, hop limit 1)
- **Managed security group** with ingress/egress rules (using `aws_vpc_security_group_*_rule`)
- **Auto-null ports** - `from_port`/`to_port` are ignored when `ip_protocol = "-1"`
- **IAM role + instance profile** with managed policy attachments and permissions boundary
- **Stop / termination protection**

### Storage

- **Root block device** - size, type, IOPS, throughput, encryption, KMS key
- **Inline EBS block devices** and **instance store** volumes
- **Standalone EBS volumes** (`aws_ebs_volume` + `aws_volume_attachment`) that can outlive the instance

### Networking

- **Elastic IP** association
- **Existing network interfaces** at boot time
- **IPv6** - address count, explicit addresses, primary IPv6
- **Secondary private IPs**, source/destination check
- **Private DNS name options** (IP-name / resource-name hostnames)
- **Maintenance options** (auto recovery)

## Naming Convention

Resources follow the standard naming pattern:

```
{region_prefix}-{resource_type}-{account_name}-{project_name}[-{name_suffix}]
```

| Resource                  | Pattern                                          | Example                          |
| ------------------------- | ------------------------------------------------ | -------------------------------- |
| Instance                  | `{region_prefix}-ec2-{account}-{project}`        | `ause1-ec2-prod-myapp`           |
| Security group            | `{region_prefix}-sg-ec2-{account}-{project}`     | `ause1-sg-ec2-prod-myapp`        |
| IAM role/instance profile | `{region_prefix}-role-ec2-{account}-{project}`   | `ause1-role-ec2-prod-myapp`      |
| Elastic IP                | `{region_prefix}-eip-ec2-{account}-{project}`    | `ause1-eip-ec2-prod-myapp`       |
| EBS volume                | `{region_prefix}-ebs-ec2-{account}-{project}-{key}` | `ause1-ebs-ec2-prod-myapp-data` |

- Region prefixes are auto-detected (e.g., `us-east-1` -> `ause1`). Override with `region_prefix` or drop it with `use_region_prefix = false`.
- Every name can be overridden explicitly (`name`, `security_group_name`, `iam_role_name`, `eip_name`, `ebs_volumes[*].name`).
- IAM role names are truncated to 64 characters. With `iam_role_use_name_prefix = true` the name is truncated to 38 characters and AWS appends a random suffix.
- All resources get `Name` and `ManagedBy = "Terraform"` tags, merged with `tags_common` and the resource-specific tag maps.

## Usage

### Basic Instance

```hcl
module "ec2" {
  source = "./terraform-aws-ec2/ec2"

  account_name = "prod"
  project_name = "myapp"

  instance_type = "t3.micro"
  subnet_id     = "subnet-xxx"

  security_group_ingress_rules = {
    https = {
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

  tags_common = {
    Environment = "prod"
  }
}
```

### Spot Instance

```hcl
module "ec2_spot" {
  source = "./terraform-aws-ec2/ec2"

  account_name = "dev"
  project_name = "batch"
  subnet_id    = "subnet-xxx"

  instance_market_options = {
    market_type = "spot"
    spot_options = {
      max_price                      = "0.02"
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }
}
```

### Session Manager (no SSH)

```hcl
module "ec2" {
  source = "./terraform-aws-ec2/ec2"

  account_name = "prod"
  project_name = "bastion"
  subnet_id    = "subnet-private"

  create_iam_instance_profile = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  security_group_egress_rules = {
    https = {
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }
}
```

### Multiple Instances

The module manages **one instance per call**. Use `for_each` in the caller and `name_suffix` to keep names unique:

```hcl
module "ec2" {
  source   = "./terraform-aws-ec2/ec2"
  for_each = toset(["web-1", "web-2"])

  account_name = "prod"
  project_name = "myapp"
  name_suffix  = each.key
  subnet_id    = "subnet-xxx"
}
```

## Examples

- [Basic](examples/basic/) - Single on-demand instance with SSH security group
- [Complete](examples/complete/) - IAM, EIP, KMS-encrypted volumes, CPU options, hibernation, placement group
- [Spot Instance](examples/spot-instance/) - One-time Spot instance via `instance_market_options`
- [Session Manager](examples/session-manager/) - Private instance managed through SSM with VPC endpoints
- [Multiple Instances](examples/multiple-instances/) - `for_each` on the module with a shared security group

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 1.0  |
| aws       | ~> 6.0  |

## Inputs

| Name                           | Description                                                 | Type          | Default                       |
| ------------------------------ | ----------------------------------------------------------- | ------------- | ----------------------------- |
| `account_name`                 | Account name for resource naming                            | `string`      | -                             |
| `project_name`                 | Project name for resource naming                            | `string`      | -                             |
| `create`                       | Controls if resources should be created                     | `bool`        | `true`                        |
| `name`                         | Instance name (auto-generated if null)                      | `string`      | `null`                        |
| `name_suffix`                  | Suffix appended to generated names                          | `string`      | `null`                        |
| `region_prefix`                | Region prefix override                                      | `string`      | `null`                        |
| `use_region_prefix`            | Include region prefix in names                              | `bool`        | `true`                        |
| `instance_type`                | Instance type                                               | `string`      | `"t3.micro"`                  |
| `ami`                          | AMI ID (overrides `ami_ssm_parameter`)                      | `string`      | `null`                        |
| `ami_ssm_parameter`            | SSM parameter with the AMI ID                               | `string`      | AL2023 x86_64                 |
| `ignore_ami_changes`           | Ignore AMI changes                                          | `bool`        | `false`                       |
| `subnet_id`                    | Subnet ID                                                   | `string`      | `null`                        |
| `instance_market_options`      | Spot / capacity-block purchasing options                    | `object`      | `null`                        |
| `metadata_options`             | Instance metadata options                                   | `object`      | IMDSv2 required, hop limit 1  |
| `root_block_device`            | Root volume configuration                                   | `object`      | `null`                        |
| `ebs_volumes`                  | Standalone EBS volumes + attachments                        | `map(object)` | `null`                        |
| `create_iam_instance_profile`  | Create IAM role and instance profile                        | `bool`        | `false`                       |
| `iam_role_policies`            | Policy ARNs to attach to the role                           | `map(string)` | `{}`                          |
| `create_security_group`        | Create managed security group                               | `bool`        | `true`                        |
| `vpc_id`                       | VPC for the security group (resolved from subnet if null)   | `string`      | `null`                        |
| `security_group_ingress_rules` | Ingress rules for managed SG                                | `map(object)` | `null`                        |
| `security_group_egress_rules`  | Egress rules for managed SG                                 | `map(object)` | allow all IPv4/IPv6           |
| `create_eip`                   | Create and associate an Elastic IP                          | `bool`        | `false`                       |
| `tags_common`                  | Common tags for all resources                               | `map(string)` | `{}`                          |

See [6-variables.tf](ec2/6-variables.tf) for the complete list of variables.

## Outputs

| Name                           | Description                                        |
| ------------------------------ | -------------------------------------------------- |
| `id`                           | Instance ID                                        |
| `arn`                          | Instance ARN                                       |
| `name`                         | Instance name                                      |
| `instance_state`               | Instance state                                     |
| `instance_lifecycle`           | `spot` / `capacity-block` when not on-demand       |
| `spot_instance_request_id`     | Spot request ID backing the instance               |
| `ami`                          | AMI used by the instance                           |
| `availability_zone`            | Availability zone                                  |
| `private_ip` / `public_ip`     | IP addresses (`public_ip` returns the EIP if any)  |
| `private_dns` / `public_dns`   | DNS names                                          |
| `primary_network_interface_id` | Primary ENI ID                                     |
| `root_block_device`            | Root block device information                      |
| `ebs_volumes`                  | Map of standalone EBS volumes                      |
| `iam_role_arn` / `iam_role_name` | IAM role                                         |
| `iam_instance_profile_arn`     | Instance profile ARN                               |
| `security_group_id`            | Managed security group ID                          |
| `eip_id` / `eip_public_ip`     | Elastic IP                                         |

See [7-outputs.tf](ec2/7-outputs.tf) for the complete list of outputs.

## Module Structure

```
terraform-aws-ec2/
├── ec2/
│   ├── 0-versions.tf          # Provider version constraints
│   ├── 0-data.tf              # Data sources (region, partition, AMI SSM parameter, subnet)
│   ├── 0-locals.tf            # Locals (region prefix, naming, tags)
│   ├── 1-instance.tf          # EC2 instance (default and ignore-AMI variants)
│   ├── 2-ebs-volumes.tf       # Standalone EBS volumes and attachments
│   ├── 3-iam.tf               # IAM role, policy attachments, instance profile
│   ├── 4-security-group.tf    # Managed security group and rules
│   ├── 5-eip.tf               # Elastic IP
│   ├── 6-variables.tf         # Input variables
│   └── 7-outputs.tf           # Output values
├── examples/
│   ├── basic/
│   ├── complete/
│   ├── spot-instance/
│   ├── session-manager/
│   └── multiple-instances/
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## License

MIT
