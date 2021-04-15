variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the bucket name"
}

variable "function" {
  description = "forms the second part of the bucket name, eg. upload"
}

variable "environment" {
  description = "environment, e.g. prod"
}

variable "alb_log_bucket" {
  description = "ALB log bucket ID"
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
}

variable "alb_target_group_port" {
  description = "TCP port of target group"
  default     = 80
}

variable "alb_target_type" {
  description = "ALB target group type, must be instance, ip, or lambda"
  default     = "instance"
}

variable "certificate_arn" {
  description = "SSL certificate ARN"
}

variable "domain_name" {
  description = "Domain name to be used in SSL certificate"
}

variable "health_check_path" {
  description = "path to be used for health check"
  default     = "login"
}

variable "health_check_matcher" {
  description = "HTTP response codes for a successful health check"
  default     = "200"
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive failed health checks required to mark the target as unhealthy"
  type        = number
  default     = 2
}

variable "http_listener" {
  description = "HTTP listener on port 80 for HTTP to HTTPS redirect"
  default     = true
}

variable "public_subnets" {
  description = "List of subnets in VPC"
}

variable "ssl_policy" {
  description = "SSL policy for ALB"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "target_id" {
  description = "EC2 instance to be used as target"
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "own_host_header_only" {
  default = false
}

variable "host" {
  default     = ""
  description = "The host to allow requests from if using own_host_header_only"
}
