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

variable "subnet_id" {
  description = "Subnet ID to launch the instance in."
  type        = string
}

variable "key_name" {
  description = "Existing key pair name for SSH access."
  type        = string
  default     = null
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to reach the instance over SSH."
  type        = string
  default     = "10.0.0.0/8"
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default = {
    Environment = "dev"
  }
}
