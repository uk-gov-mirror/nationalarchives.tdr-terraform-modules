resource "aws_efs_file_system" "file_system" {
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
  encrypted  = true
  kms_key_id = data.aws_kms_key.efs_kms_key.arn
  tags = merge(
    var.common_tags,
    map(
      "Name", local.efs_volume_name,
    )
  )
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.file_system.id
  posix_user {
    gid = 1001
    uid = 1001
  }
  root_directory {
    path = var.access_point_path
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = 755
    }
  }
}

resource "aws_efs_file_system_policy" "file_system_policy" {
  file_system_id = aws_efs_file_system.file_system.id
  policy         = templatefile("${path.module}/templates/${var.policy}.json.tpl", { file_system_arn = aws_efs_file_system.file_system.arn })
}
