variable "event_pattern" {}
variable "log_group_event_target_arn" {
  description = "A Cloudwatch log group ARN to attach to the event"
  default     = ""
}
variable "lambda_event_target_arn" {
  description = "A Lambda ARN to attach to the event"
  type        = list(string)
  default     = []
}
