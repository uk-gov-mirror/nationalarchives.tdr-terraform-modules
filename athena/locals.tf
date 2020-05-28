locals {
  workspace   = lower(terraform.workspace)
  environment = local.workspace == "default" ? "mgmt" : local.workspace
  athena_name = "${var.project}_${var.function}_${local.environment}"
}
