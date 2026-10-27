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
  default     = "bastion"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (the first one hosts the instance; all of them host the VPC endpoints)."
  type        = list(string)
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default = {
    Environment = "dev"
  }
}
