output "file_format_build_sg_id" {
  value = aws_security_group.ecs_run_efs.*.id
}

output "grafana_ecs_task_role_name" {
  value = aws_iam_role.grafana_ecs_task.*.name
}
