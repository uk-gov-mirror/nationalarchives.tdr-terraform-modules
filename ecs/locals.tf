locals {
  workspace               = lower(terraform.workspace)
  environment             = local.workspace == "default" ? "mgmt" : local.workspace
  count_file_format_build = var.file_format_build == true ? 1 : 0
}
