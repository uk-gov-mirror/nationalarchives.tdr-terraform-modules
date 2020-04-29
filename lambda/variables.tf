variable "environment" {}

variable "common_tags" {}

variable "project" {}

variable "function" {}

variable "policy" {}

variable "runtime" {}

variable "handler" {}

variable "lambda_subnets" {}

variable "timeout" {
  default = 3
}

variable "memory_size" {
  default = 128
}

variable "vpc_id" {}