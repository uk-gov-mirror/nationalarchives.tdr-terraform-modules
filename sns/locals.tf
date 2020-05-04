locals {
  workspace      = lower(terraform.workspace)
  environment    = local.workspace == "default" ? "mgmt" : local.workspace
  sns_topic_name = "${var.project}-${var.function}-${local.environment}"
}
