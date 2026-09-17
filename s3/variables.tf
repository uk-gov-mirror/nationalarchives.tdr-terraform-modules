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
# If this is set, the id will be used to set bucket policies for the user equivalent to 'FULL_CONTROL'.Permissions value ignored
# Only specified for the log bucket and used in the secure_transport.json.tpl
variable "canonical_user_grants" {
  description = "A list of canonical user IDs and their permissions. If this is set, you cannot use a canned ACL"
  type        = list(object({ id = string, permissions = list(string) }))
  default     = []
}

variable "versioning" {
  default = true
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

variable "bucket_key_enabled" {
  description = "Enable bucket key"
  default     = false
}

variable "read_access_role_arns" {
  description = "IAM roles requiring read access to bucket"
  default     = []
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

variable "lambda_notification" {
  description = "Notify Lambda on upload to main S3 bucket"
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

variable "lambda_arn" {
  description = "The lambda arn to send S3 event messages to"
  default     = ""
}

variable "cloudfront_distribution_arns" {
  description = "ARNs of Cloudfront distributions interacting with the bucket"
  default     = []
}

variable "aws_logs_delivery_account_id" {
  description = "AWS log delivery account ID"
  default     = ""
}

variable "lifecycle_rules" {
  description = "List of maps describing configuration of object lifecycle management for bucket"
  type        = any
  default     = []
}

variable "s3_bucket_additional_tags" {
  description = "Set of tags to be applied to the S3 bucket only"
  default     = null
}

variable "s3_logs_bucket_additional_tags" {
  description = "Set of tags to be applied to the S3 logs bucket only"
  default     = null
}

variable "aws_backup_local_role_arn" {
  description = "Local account role for the central backup"
  default     = ""
}

variable "bucket_owner_object_ownership" {
  description = "Toggle to enforce bucket owner object control on bucket. Should be 'true' but toggling to ensure no breaking changes"
  default     = false
}

variable "enable_request_metrics_all" {
  description = "Enable the additional request metrics for all objects in this bucket"
  default     = false
}

variable "request_metrics_filters" {
  description = "Enable the additional request metrics with filters.  Expects a map of Filter objects as documented in aws_s3_bucket_metric. Key is the filter name"
  type = map(object({
    access_point = optional(string)
    prefix       = optional(string)
    tags         = optional(map(any))
  }))
  default = {}
}

variable "log_bucket_lifecycle_rules" {
  description = "List of maps describing configuration of object lifecycle management for the activity log buckets"
  type        = any
  default     = []
}
