locals {
  domain = var.environment_full_name == "production" ? "${var.project}.${var.domain}" : "${var.project}-${var.environment_full_name}.${var.domain}"
  email  = var.email_address == "" ? data.aws_ssm_parameter.notification_email_prefix.value : var.email_address
}
