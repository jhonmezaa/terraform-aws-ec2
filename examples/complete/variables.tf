variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Account name for resource naming."
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string
  default     = "webapp"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_id" {
  description = "Public subnet ID to launch the instance in (an Elastic IP is attached)."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone of the subnet."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Existing key pair name."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default = {
    Environment = "prod"
  }
}
