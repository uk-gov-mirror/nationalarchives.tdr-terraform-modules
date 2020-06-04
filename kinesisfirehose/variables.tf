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

variable "log_type" {
  description = "type of log, used in the S3 prefix"
  default     = "flowlogs"
}

variable "destination_bucket" {
  description = "Name of destination S3 bucket for kinesis firehose stream"
  default     = ""
}

variable "queries" {
  description = "comma separated list of queries"
  default     = []
}

variable "cloudwatch_log_group_name" {
  description = "name of Cloudwatch log group for subscription filter"
}
