# Basic EC2 Example

This example creates a single on-demand EC2 instance with:

- Latest Amazon Linux 2023 AMI resolved from the public SSM parameter
- IMDSv2 required (module default)
- Managed security group allowing SSH from a trusted CIDR and all outbound traffic

Resulting names (in `us-east-1`):

- Instance: `ause1-ec2-dev-webapp`
- Security group: `ause1-sg-ec2-dev-webapp`

## Usage

```bash
terraform init
terraform plan -var="subnet_id=subnet-xxx" -var="key_name=my-key"
terraform apply
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 1.0  |
| aws       | ~> 6.0  |
