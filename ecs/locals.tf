locals {
  count_file_format_build        = var.file_format_build == true ? 1 : 0
  count_grafana_build            = var.grafana_build == true ? 1 : 0
  count_consignment_export       = var.consignment_export == true ? 1 : 0
  consignment_export_cluster_arn = var.consignment_export == true && length(aws_ecs_cluster.consignment_export_cluster) > 0 ? aws_ecs_cluster.consignment_export_cluster.*.arn[0] : ""
  consignment_export_task_arn    = var.consignment_export == true && length(aws_ecs_task_definition.consignment_export_task_definition) > 0 ? aws_ecs_task_definition.consignment_export_task_definition.*.arn[0] : ""
  environment                    = local.workspace == "default" ? "mgmt" : local.workspace
  project_prefix                 = upper(var.project)
  workspace                      = lower(terraform.workspace)
}
