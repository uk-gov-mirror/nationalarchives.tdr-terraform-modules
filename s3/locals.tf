locals {
  workspace            = lower(terraform.workspace)
  environment          = local.workspace == "default" ? "mgmt" : local.workspace
  standard_bucket_name = "${var.project}-${var.function}-${local.environment}"
  global_bucket_name   = "${var.project}-${var.function}"
  bucket_name          = var.environment_suffix == true ? local.standard_bucket_name : local.global_bucket_name
  sns_topic_arn        = var.sns_topic_arn == "" ? "arn:aws:sns:${var.sns_topic_region}:${data.aws_caller_identity.current.account_id}:${var.project}-logs-${local.environment}" : var.sns_topic_arn
}
