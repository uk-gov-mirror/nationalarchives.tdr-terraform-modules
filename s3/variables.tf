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