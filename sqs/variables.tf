variable "region" {
  description = "SQS region"
  default     = "eu-west-2"
}

variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "sns_topic_arns" {
  description = "list of SNS topics the SQS subscribes to"
  type        = list(string)
  default     = []
}
