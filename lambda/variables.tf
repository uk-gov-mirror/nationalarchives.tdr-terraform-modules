variable "environment" {}

variable "common_tags" {}

variable "lambda_subnets" {}

variable "project" {}

variable "vpc_id" {}

variable "apply_resource" {
  description = "use to conditionally apply resource from the calling module"
  default     = true
}

variable "lambda_yara_av" {
  description = "deploy Lambda function to run yara av checks on files"
  default     = false
}
