variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Account name for resource naming."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string
  default     = "batch"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR allowed to reach the instance over HTTPS."
  type        = string
  default     = "10.0.0.0/16"
}

variable "spot_max_price" {
  description = "Maximum hourly price for the Spot instance (USD). Null uses the on-demand price as cap."
  type        = string
  default     = "0.02"
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default = {
    Environment = "dev"
  }
}
