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
  default     = "webapp"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used to spread the instances."
  type        = list(string)
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default = {
    Environment = "dev"
  }
}
