variable "aws_account_level" {
  description = "set to true if configuring at the AWS account level"
  default     = false
}

variable "support_group" {
  description = "group giving permissions to manage support calls with AWS"
  default     = "support"
}