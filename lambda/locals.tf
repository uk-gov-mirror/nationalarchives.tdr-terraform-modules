locals {
  count_av_yara = var.apply_resource == true && var.lambda_yara_av == true ? 1 : 0
  workspace = lower(terraform.workspace) environment = local.workspace == "default" ? "mgmt" : local.workspace
}