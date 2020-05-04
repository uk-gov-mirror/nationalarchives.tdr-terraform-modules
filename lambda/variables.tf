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

variable "lambda_log_data" {
  description = "deploy Lambda function to copy S3 from one bucket to another via SNS notifications"
  default     = false
}

variable "target_s3_bucket" {
  description = "Target S3 bucket ARN used for the Lambda log data function"
  default     = ""
}

variable "log_data_sns_topic" {
  description = "SNS topic ARN used for the Lambda log data function"
  default     = ""
}