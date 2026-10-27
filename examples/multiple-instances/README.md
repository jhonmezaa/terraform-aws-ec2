# Multiple Instances Example

The module manages **one instance per invocation**. This example shows the recommended
pattern to create several instances: `for_each` on the module call plus `name_suffix`
so every generated name stays unique.

- 3 instances (`web-1`, `web-2`, `worker`) with different instance types and root sizes
- A shared security group created in the caller (`create_security_group = false`)
- Per-instance `Role` tag

Resulting names (in `us-east-1`):

- `ause1-ec2-dev-webapp-web-1`
- `ause1-ec2-dev-webapp-web-2`
- `ause1-ec2-dev-webapp-worker`

## Usage

```bash
terraform init
terraform plan -var="vpc_id=vpc-xxx" -var='subnet_ids=["subnet-xxx","subnet-yyy"]'
terraform apply
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 1.0  |
| aws       | ~> 6.0  |
