# Session Manager Example

This example creates a private EC2 instance that is administered exclusively through
AWS Systems Manager Session Manager (no SSH, no key pair, no inbound rules):

- IAM role + instance profile with `AmazonSSMManagedInstanceCore`
- Managed security group with **no ingress** and egress limited to HTTPS towards the VPC
- Interface VPC endpoints for `ssm`, `ssmmessages` and `ec2messages`, so the instance
  does not need internet access (NAT gateway optional)

Resulting names (in `us-east-1`):

- Instance: `ause1-ec2-dev-bastion`
- IAM role / instance profile: `ause1-role-ec2-dev-bastion`
- Security group: `ause1-sg-ec2-dev-bastion`

## Usage

```bash
terraform init
terraform plan -var="vpc_id=vpc-xxx" -var='private_subnet_ids=["subnet-xxx","subnet-yyy"]'
terraform apply

# Connect
aws ssm start-session --target "$(terraform output -raw instance_id)"
```

> The VPC must have DNS hostnames and DNS resolution enabled for private DNS on the endpoints.
> If the VPC already has these endpoints, remove the `aws_vpc_endpoint` resources from this example.

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 1.0  |
| aws       | ~> 6.0  |
