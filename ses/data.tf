data "aws_ssm_parameter" "notification_email_prefix" {
  name = "/mgmt/notification/email/prefix"
}