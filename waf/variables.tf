variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "environment" {
  description = "environment, e.g. prod"
}

variable "alb_target_group_arn" {
  description = "ALB target group ARN for WAF rule association"
}

variable "trusted_ips" {
  description = "trusted IP addresses in csv format"
}

variable "restricted_uri" {
  description = "Resricted URI"
  default     = ""
}
