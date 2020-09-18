output "file_format_build_sg_id" {
  value = aws_security_group.ecs_run_efs.*.id
}