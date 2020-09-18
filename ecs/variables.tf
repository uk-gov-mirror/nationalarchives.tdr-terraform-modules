variable "access_point" {
  default = {}
}

variable "alb_target_group_arn" {
  default = ""
}

variable "app_name" {
  default = ""
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "common_tags" {}

variable "file_format_build" {
  default = false
}

variable "file_system" {
  default = {}
}

variable "grafana_build" {
  default = false
}

variable "project" {}

variable "vpc_tag_name" {
  default = ""
}
