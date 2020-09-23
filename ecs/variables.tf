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

variable "ecs_task_security_group_id" {
  default = ""
}

variable "file_format_build" {
  default = false
}

variable "file_system_id" {
  default = ""
}

variable "grafana_build" {
  default = false
}

variable "project" {}

variable "vpc_private_subnet_ids" {
  default = []
}
