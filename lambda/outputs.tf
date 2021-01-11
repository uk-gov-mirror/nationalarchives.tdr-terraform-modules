output "antivirus_lambda_sg_id" {
  value = aws_security_group.allow_efs_lambda_av.*.id
}

output "download_files_lambda_sg_id" {
  value = aws_security_group.allow_efs_lambda_download_files.*.id
}

output "file_format_lambda_sg_id" {
  value = aws_security_group.allow_efs_lambda_file_format.*.id
}

output "checksum_lambda_sg_id" {
  value = aws_security_group.allow_efs_lambda_checksum.*.id
}

output "ecr_scan_notification_lambda_arn" {
  value = aws_lambda_function.notifications_lambda_function.*.arn
}

output "ecr_scan_lambda_arn" {
  value = aws_lambda_function.ecr_scan_lambda_function.*.arn
}

output "export_api_authoriser_arn" {
  value = local.export_api_authoriser_arn
}
