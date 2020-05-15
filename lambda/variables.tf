variable "region" {
  default = "eu-west-2"
}

variable "common_tags" {}

variable "project" {}

variable "apply_resource" {
  description = "use to conditionally apply resource from the calling module"
  default     = true
}

variable "lambda_yara_av" {
  description = "deploy Lambda function to run yara av checks on files"
  default     = false
}

variable "lambda_log_data" {
  description = "deploy Lambda function to copy S3 from one bucket to another via SNS notifications"
  default     = false
}

variable "lambda_api_update_av" {
  description = "depoly Lambda function to update the api for av checks"
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

variable "auth_url" {
  description = "The url of the keycloak server"
  default     = ""
}

variable "api_url" {
  description = "The url of the graphql api"
  default     = ""
}
