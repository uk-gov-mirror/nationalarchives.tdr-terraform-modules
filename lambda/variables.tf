variable "environment" {
  default = "intg"
}

variable "common_tags" {}

variable "lambda_subnets" {
  default = []
}

variable "project" {}

variable "vpc_id" {
  default = ""
}

variable "apply_resource" {
  description = "use to conditionally apply resource from the calling module"
  default     = true
}

variable "lambda_yara_av" {
  description = "deploy Lambda function to run yara av checks on files"
  default     = false
}

variable "region" {
  default = "eu-west-2"
}