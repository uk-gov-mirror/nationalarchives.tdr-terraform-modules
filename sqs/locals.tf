locals {
  workspace   = lower(terraform.workspace)
  environment = local.workspace == "default" ? "mgmt" : local.workspace
  sqs_name    = "${var.project}-${var.function}-${local.environment}"
}