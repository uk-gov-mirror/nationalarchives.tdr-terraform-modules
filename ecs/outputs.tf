output "file_format_build_sg_id" {
  value = aws_security_group.ecs_run_efs.*.id
}

output "grafana_ecs_task_role_name" {
  value = aws_iam_role.grafana_ecs_task.*.name
}

output "consignment_export_sg_id" {
  value = aws_security_group.consignment_export_ecs_run_efs.*.id
}

output "consignment_export_task_arn" {
  value = local.consignment_export_task_arn
}

output "consignment_export_cluster_arn" {
  value = local.consignment_export_cluster_arn
}