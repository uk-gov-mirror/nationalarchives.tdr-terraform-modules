variable "region" {
  description = "SNS topic region"
  default     = "eu-west-2"
}

variable "apply_resource" {
  description = "use to conditionally apply resource from the calling module"
  default     = true
}

variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the bucket name"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "sns_policy" {
  description = "allows a custom SNS policy to be set"
  default     = "default"
}

variable "kms_key_arn" {
  default = ""
}