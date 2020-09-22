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

variable "depends_on_vpc" {
  description = "Vpc for ECS task. Ensures Vpc exists before creating ECS task"
  type = any
}

variable "file_format_build" {
  default = false
}

variable "file_system" {
  default = {}
}

variable "file_system_id" {
  default = ""
}

variable "grafana_build" {
  default = false
}

variable "project" {}

variable "vpc_name_tag" {
  default = ""
}
