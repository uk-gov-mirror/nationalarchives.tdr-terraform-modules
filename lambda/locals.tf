locals {
  workspace                 = lower(terraform.workspace)
  environment               = local.workspace == "default" ? "mgmt" : local.workspace
  count_av_yara             = var.apply_resource == true && var.lambda_yara_av == true ? 1 : 0
  count_checksum            = var.apply_resource == true && var.lambda_checksum == true ? 1 : 0
  count_log_data            = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  count_api_update          = var.apply_resource && var.lambda_api_update == true ? 1 : 0
  count_file_format         = var.apply_resource && var.lambda_file_format == true ? 1 : 0
  count_file_format_subnets = var.apply_resource && var.lambda_file_format == true ? 2 : 0
  count_log_data_mgmt       = var.apply_resource == true && var.lambda_log_data == true && local.environment == "mgmt" ? 1 : 0
  api_update_queue_name     = "tdr-api-update-${local.environment}"
  api_update_queue          = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.api_update_queue_name}"
  api_update_queue_url      = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${local.api_update_queue_name}"
  antivirus_queue           = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-antivirus-${local.environment}"
  checksum_queue            = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-checksum-${local.environment}"
  checksum_queue_url        = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-checksum-${local.environment}"
  file_format_queue         = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-file-format-${local.environment}"
  file_format_queue_url     = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-file-format-${local.environment}"
}
