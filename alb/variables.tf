variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the bucket name"
}

variable "function" {
  description = "forms the second part of the bucket name, eg. upload"
}

variable "environment" {
  description = "environment, e.g. prod"
}

variable "alb_log_bucket" {
  description = "ALB log bucket ID"
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
}

variable "domain_name" {
  description = "Domain name to be used in SSL certificate"
}

variable "health_check_path" {
  description = "path to be used for health check"
  default = "login"
}

variable "public_subnets" {
  description = "List of subnets in VPC"
}

variable "ssl_policy" {
  description = "SSL policy for ALB"
  default = "ELBSecurityPolicy-FS-2018-06"
}

variable "target_id" {
  description = "EC2 instance to be used as target"
}

variable "vpc_id" {
  description = "VPC ID"
}