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
  description = "forms the second part of the bucket name, eg. upload"
}

variable "environment_suffix" {
  description = "includes environment suffix in bucket name"
  default     = true
}

variable "acl" {
  default = "private"
}

variable "versioning" {
  default = true
}

variable "version_lifecycle" {
  default = false
}

variable "abort_incomplete_uploads" {
  default = false
}

variable "block_public_acls" {
  default = true
}

variable "block_public_policy" {
  default = true
}

variable "ignore_public_acls" {
  default = true
}

variable "restrict_public_buckets" {
  default = true
}

variable "access_logs" {
  description = "creates a logging bucket and configures access logs"
  default     = true
}

variable "bucket_policy" {
  description = "bucket policy within templates folder"
  default     = "secure_transport"
}

variable "kms_key_id" {
  description = "KMS Key ID to encrypt S3 bucket"
  default     = ""
}

variable "cors_urls" {
  description = "frontend URLs that are allowed to make cross-origin request to the bucket"
  type        = list(string)
  default     = []
}

variable "force_destroy" {
  description = "destroys S3 bucket on terraform destroy, even if there are files inside the bucket"
  default     = true
}

variable "sns_notification" {
  description = "Notify SNS on upload to main S3 bucket"
  default     = false
}

variable "sns_topic_region" {
  description = "SNS topic region for upload to main S3 bucket"
  default     = "eu-west-2"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for upload to main S3 bucket"
  default     = ""
}

variable "log_data_sns_topic_arn" {
  description = "SNS topic ARN for log data aggregation"
  default     = ""
}

variable "log_data_sns_notification" {
  description = "Notify SNS on upload to S3 log bucket"
  default     = true
}

variable "log_data_sns_topic_region" {
  description = "Region for log data SNS topic"
  default     = "eu-west-2"
}
