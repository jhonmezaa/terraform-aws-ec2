# =============================================================================
# Basic EC2 Example
# =============================================================================
# Creates a single on-demand instance with:
# - Latest Amazon Linux 2023 AMI resolved from SSM
# - IMDSv2 enforced (module default)
# - Managed security group with SSH from a trusted CIDR and all outbound
# =============================================================================

provider "aws" {
  region = var.region
}

module "ec2" {
  source = "../../ec2"

  account_name = var.account_name
  project_name = var.project_name

  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  security_group_ingress_rules = {
    ssh = {
      description = "Allow SSH from trusted CIDR"
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.ssh_allowed_cidr
    }
  }

  tags_common = var.tags
}
