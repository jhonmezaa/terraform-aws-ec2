# =============================================================================
# Complete EC2 Example
# =============================================================================
# Exercises most of the module features on a single instance:
# - IAM role + instance profile, managed security group, Elastic IP
# - Encrypted root volume and additional KMS-encrypted EBS volumes
# - CPU options, hibernation, placement group, capacity reservation preference
# - IMDSv2 with instance metadata tags, maintenance and private DNS options
# - user_data_base64 and custom timeouts
# =============================================================================

provider "aws" {
  region = var.region
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable --now nginx
  EOT
}

module "ec2" {
  source = "../../ec2"

  account_name = var.account_name
  project_name = var.project_name

  # Instance
  instance_type     = "c5.xlarge" # supports cpu_options and hibernation
  availability_zone = var.availability_zone
  subnet_id         = var.subnet_id
  vpc_id            = var.vpc_id
  key_name          = var.key_name
  monitoring        = true
  ebs_optimized     = true
  placement_group   = aws_placement_group.this.name

  disable_api_stop        = false
  disable_api_termination = false
  force_destroy           = true

  # Only one of hibernation / enclave_options_enabled can be enabled
  hibernation = true

  cpu_options = {
    core_count       = 2
    threads_per_core = 1
  }

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  maintenance_options = {
    auto_recovery = "default"
  }

  private_dns_name_options = {
    hostname_type                     = "resource-name"
    enable_resource_name_dns_a_record = true
  }

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  timeouts = {
    create = "15m"
    update = "15m"
    delete = "20m"
  }

  # Block devices (volume_tags disabled so root_block_device.tags can be used)
  enable_volume_tags = false
  root_block_device = {
    encrypted  = true
    kms_key_id = aws_kms_key.this.arn
    type       = "gp3"
    size       = 50
    throughput = 200
    tags = {
      Name = "${var.account_name}-${var.project_name}-root"
    }
  }

  ebs_volumes = {
    data = {
      device_name = "/dev/sdf"
      size        = 20
      type        = "gp3"
      throughput  = 200
      kms_key_id  = aws_kms_key.this.arn
      tags = {
        MountPoint = "/mnt/data"
      }
    }
    logs = {
      device_name = "/dev/sdg"
      size        = 10
      kms_key_id  = aws_kms_key.this.arn
      tags = {
        MountPoint = "/var/log/app"
      }
    }
  }

  # IAM
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for the complete EC2 example"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }

  # Security group
  security_group_ingress_rules = {
    http = {
      description = "Allow HTTP from anywhere"
      from_port   = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_from_vpc = {
      description = "Allow all traffic from the VPC"
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc_cidr
    }
  }

  # Elastic IP
  create_eip = true

  instance_tags = {
    Backup = "daily"
  }

  tags_common = var.tags
}

# =============================================================================
# Supporting Resources
# =============================================================================

resource "aws_kms_key" "this" {
  description             = "KMS key for ${var.account_name}-${var.project_name} EC2 volumes"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_placement_group" "this" {
  name     = "${var.account_name}-${var.project_name}-spread"
  strategy = "spread"

  tags = var.tags
}
