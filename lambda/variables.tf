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

variable "lambda_checksum" {
  description = "deploy Lambda function to run the checksum calculation"
  default     = false
}

variable "lambda_log_data" {
  description = "deploy Lambda function to copy S3 from one bucket to another via SNS notifications"
  default     = false
}

variable "lambda_api_update" {
  description = "depoly Lambda function to update the api"
  default     = false
}

variable "lambda_file_format" {
  description = "deploy Lambda function to run the file format extraction"
  default     = false
}

variable "lambda_download_files" {
  description = "deploy Lambda function to download files to EFS"
  default     = false
}

variable "lambda_ecr_scan_notifications" {
  description = "deploy Lambda function to send notifications from ECR scans"
  default     = false
}

variable "lambda_ecr_scan" {
  description = "deploy Lambda function to run ECR image scans"
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

variable "keycloak_backend_checks_client_secret" {
  description = "Keycloak backend checks client secret"
  default     = ""
}

variable "backend_checks_efs_access_point" {
  description = "The access point for the efs volume used by the backend checks"
  default     = ""
}

variable "backend_checks_efs_root_directory_path" {
  description = "The root directory of the efs volume used by the backend checks"
  default     = ""
}

variable "vpc_id" {
  description = "The VPC ID"
  default     = ""
}

variable "file_system_id" {
  default = ""
}

variable "s3_sns_topic" {
  default = ""
}

variable "use_efs" {
  default = false
}

variable "mount_target_ids" {
  default = []
  type    = list(string)
}

variable "event_rule_arns" {
  type    = set(string)
  default = []
}

variable "periodic_ecr_image_scan_event_arn" {
  default = ""
}