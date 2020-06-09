locals {
  workspace                      = lower(terraform.workspace)
  environment                    = local.workspace == "default" ? "mgmt" : local.workspace
  count_av_yara                  = var.apply_resource == true && var.lambda_yara_av == true ? 1 : 0
  count_checksum                 = var.apply_resource == true && var.lambda_checksum == true ? 1 : 0
  count_log_data                 = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  count_api_update_av            = var.apply_resource && var.lambda_api_update_av == true ? 1 : 0
  count_log_data_mgmt            = var.apply_resource == true && var.lambda_log_data == true && local.environment == "mgmt" ? 1 : 0
  antivirus_update_queue_name    = "tdr-api-update-antivirus-${local.environment}"
  api_update_antivirus_queue     = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.antivirus_update_queue_name}"
  api_update_antivirus_queue_url = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${local.antivirus_update_queue_name}"
  antivirus_queue                = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-antivirus-${local.environment}"
  checksum_queue                 = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-checksum-${local.environment}"
  checksum_queue_url             = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-checksum-${local.environment}"
  api_update_checksum_queue_url  = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-api-update-checksum-${local.environment}"
  api_update_checksum_queue      = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-api-update-checksum-${local.environment}"
}