# Complete EC2 Example

This example creates a production-like EC2 instance exercising most module features:

- `c5.xlarge` with custom CPU options (2 cores, 1 thread per core) and hibernation
- Spread placement group and `open` capacity reservation preference
- IMDSv2 required with instance metadata tags and hop limit 2
- Auto recovery, resource-name based private DNS hostname
- KMS-encrypted gp3 root volume plus two standalone EBS volumes (`data`, `logs`)
- IAM role + instance profile with SSM and CloudWatch Agent policies
- Managed security group (HTTP/HTTPS from anywhere, all traffic from the VPC)
- Elastic IP
- `user_data_base64` with replace-on-change and custom timeouts

Resulting names (in `us-east-1`):

| Resource       | Name                              |
| -------------- | --------------------------------- |
| Instance       | `ause1-ec2-prod-webapp`           |
| Security group | `ause1-sg-ec2-prod-webapp`        |
| IAM role       | `ause1-role-ec2-prod-webapp`      |
| Elastic IP     | `ause1-eip-ec2-prod-webapp`       |
| EBS volumes    | `ause1-ebs-ec2-prod-webapp-data`, `ause1-ebs-ec2-prod-webapp-logs` |

## Usage

```bash
terraform init
terraform plan \
  -var="vpc_id=vpc-xxx" \
  -var="vpc_cidr=10.0.0.0/16" \
  -var="subnet_id=subnet-xxx" \
  -var="availability_zone=us-east-1a"
terraform apply
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 1.3  |
| aws       | ~> 6.0  |
