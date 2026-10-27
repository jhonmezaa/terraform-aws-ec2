# Spot Instance Example

This example launches a Spot instance using `instance_market_options` on `aws_instance`
(no separate `aws_spot_instance_request` resource):

- One-time Spot request with a capped `max_price`
- `terminate` interruption behavior (one-time requests do not support `stop`/`hibernate`)
- Encrypted gp3 root volume
- Unlimited CPU credits on a burstable `t3.small`
- Managed security group allowing HTTPS from the VPC CIDR

> To use `stop` or `hibernate` as interruption behavior, set `spot_instance_type = "persistent"`.

## Usage

```bash
terraform init
terraform plan -var="subnet_id=subnet-xxx" -var="vpc_cidr=10.0.0.0/16"
terraform apply
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 1.0  |
| aws       | ~> 6.0  |
