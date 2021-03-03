output "access_point" {
  value = aws_efs_access_point.access_point
}

output "file_system_id" {
  value = aws_efs_file_system.file_system.id
}

output "root_directory_path" {
  value = local.root_directory_path
}

output "private_subnets" {
  value = aws_subnet.efs_private.*.id
}

output "mount_target_zero" {
  value = aws_efs_mount_target.mount_target_az_zero
}

output "mount_target_one" {
  value = aws_efs_mount_target.mount_target_az_one
}

