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

variable "apply_resource" {
  description = "use to conditionally apply resource from the calling module"
  default     = true
}

variable "sqs_policy" {
  description = "allows a custom SQS policy to be set"
  default     = "default"
}

variable "dead_letter_queue" {
  description = "The dead letter queue for failed messages to be sent to"
  default     = ""
}

variable "redrive_maximum_receives" {
  description = "The maximum number of receives if using a redrive policy"
  default     = 0
}