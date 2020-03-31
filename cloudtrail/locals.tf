locals {
  workspace            = lower(terraform.workspace)
  environment          = local.workspace == "default" ? "mgmt" : local.workspace
  cloudtrail_name      = "${var.project}-${var.function}-${local.environment}"
  cloudtrail_prefix    = "${var.project}-${local.environment}"
}
