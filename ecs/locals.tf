locals {
  count_file_format_build = var.file_format_build == true ? 1 : 0
  count_grafana_build     = var.grafana_build == true ? 1 : 0
  environment             = local.workspace == "default" ? "mgmt" : local.workspace
  project_prefix          = upper(var.project)
  workspace               = lower(terraform.workspace)
}
