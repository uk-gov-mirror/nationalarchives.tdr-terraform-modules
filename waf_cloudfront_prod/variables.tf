variable "common_tags" {
  description = "tags used across the project"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "environment" {
  description = "environment, e.g. prod"
}

variable "allowlist_ips" {
  description = "Allowed IPs"
  type        = list(string)
}

variable "blocklist_ips" {
  description = "Blocked IPS"
  type        = list(string)
}

variable "log_retention_period_days" {
  description = "How long in days to keep logs in cloudwatch logs"
  type        = number
  default     = 30
}

variable "rate_limit" {
  description = "The maximum number of requests to allow during the specified time window between 10 - 2,000,000,000"
  type        = number
  default     = 250
}

variable "rate_limit_evaluation_window_secs" {
  description = "The amount of time to use for request counts - valid values are in seconds (60 120 300 600)"
  type        = number
  default     = 600
}
