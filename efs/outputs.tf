output "access_point" {
  value = aws_efs_access_point.access_point
}

output "file_system_id" {
  value = aws_efs_file_system.file_system.id
}
