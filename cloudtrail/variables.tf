variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms part of the resource name"
}

variable "function" {
  description = "function, forms part of the resource name"
  default     = "cloudtrail"
}


variable "s3_bucket_name" {
  description = "Name of the S3 bucket to be used for CloudTrail logs"
}

variable "is_multi_region_trail" {
  description = "Enable collection of CloudTrail logs across all regions"
  default     = true
}

variable "include_global_service_events" {
  description = "Include global events, e.g. IAM"
  default     = true
}