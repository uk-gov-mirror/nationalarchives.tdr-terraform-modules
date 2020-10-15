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
variable "rule_name" {}
variable "rule_description" {
  default = ""
}
variable "event_variables" {
  type        = map(string)
  default     = {}
  description = "A map of variables to pass to specific event patterns"
}