locals {
  workspace      = lower(terraform.workspace)
  environment    = local.workspace == "default" ? "mgmt" : local.workspace
  sns_topic_name = "${var.project}-${var.function}-${local.environment}"
  sns_topic_arn  = var.apply_resource == true ? "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.project}-${var.function}-${local.environment}" : ""
}
