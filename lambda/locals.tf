locals {
  workspace                           = lower(terraform.workspace)
  environment                         = local.workspace == "default" ? "mgmt" : local.workspace
  count_av_yara                       = var.apply_resource == true && var.lambda_yara_av == true ? 1 : 0
  count_checksum                      = var.apply_resource == true && var.lambda_checksum == true ? 1 : 0
  count_log_data                      = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  count_api_update                    = var.apply_resource && var.lambda_api_update == true ? 1 : 0
  count_file_format                   = var.apply_resource && var.lambda_file_format == true ? 1 : 0
  count_log_data_mgmt                 = var.apply_resource == true && var.lambda_log_data == true && local.environment == "mgmt" ? 1 : 0
  count_download_files                = var.apply_resource == true && var.lambda_download_files == true ? 1 : 0
  count_notifications                 = var.apply_resource == true && var.lambda_ecr_scan_notifications == true ? 1 : 0
  count_ecr_scan                      = var.apply_resource == true && var.lambda_ecr_scan == true ? 1 : 0
  count_efs                           = var.apply_resource == true && var.use_efs ? 1 : 0
  count_create_db_users               = var.apply_resource == true && var.lambda_create_db_users ? 1 : 0
  count_export_api_authoriser         = var.apply_resource == true && var.lambda_export_authoriser == true ? 1 : 0
  api_update_function_name            = "${var.project}-api-update-${local.environment}"
  checksum_function_name              = "${var.project}-checksum-${local.environment}"
  create_db_users_function_name       = "${var.project}-create-db-users-${local.environment}"
  download_files_function_name        = "${var.project}-download-files-${local.environment}"
  export_api_authoriser_function_name = "${var.project}-export-api-authoriser-${local.environment}"
  file_format_function_name           = "${var.project}-file-format-${local.environment}"
  log_data_function_name              = "${var.project}-log-data-${local.environment}"
  notifications_function_name         = "${var.project}-notifications-${local.environment}"
  yara_av_function_name               = "${var.project}-yara-av-${local.environment}"
  api_update_queue_name               = "tdr-api-update-${local.environment}"
  api_update_queue                    = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.api_update_queue_name}"
  api_update_queue_url                = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${local.api_update_queue_name}"
  antivirus_queue                     = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-antivirus-${local.environment}"
  antivirus_queue_url                 = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-antivirus-${local.environment}"
  checksum_queue                      = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-checksum-${local.environment}"
  checksum_queue_url                  = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-checksum-${local.environment}"
  download_files_queue                = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-download-files-${local.environment}"
  download_files_queue_url            = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-download-files-${local.environment}"
  file_format_queue                   = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-file-format-${local.environment}"
  file_format_queue_url               = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-file-format-${local.environment}"
  export_api_authoriser_arn           = var.apply_resource == true && var.lambda_export_authoriser == true && length(aws_lambda_function.export_api_authoriser_lambda_function) > 0 ? aws_lambda_function.export_api_authoriser_lambda_function.*.arn[0] : ""
}
