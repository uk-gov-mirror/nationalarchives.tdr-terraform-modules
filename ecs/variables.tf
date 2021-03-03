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

variable "consignment_export" {
  default = false
}

variable "grafana_database_type" {
  default = "postgres"
}

variable "project" {}

variable "vpc_private_subnet_ids" {
  default = []
}

variable "api_url" {
  default = ""
}

variable "auth_url" {
  default = ""
}

variable "clean_bucket" {
  default = ""
}

variable "output_bucket" {
  default = ""
}

variable "backend_client_secret_path" {
  default = ""
}

variable "vpc_id" {
  default = ""
}