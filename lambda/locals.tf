locals {
  workspace           = lower(terraform.workspace)
  environment         = local.workspace == "default" ? "mgmt" : local.workspace
  count_av_yara       = var.apply_resource == true && var.lambda_yara_av == true ? 1 : 0
  count_log_data      = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  count_api_update_av = var.apply_resource && var.lambda_api_update_av == true ? 1 : 0
  count_log_data_mgmt = var.apply_resource == true && var.lambda_log_data == true && local.environment == "mgmt" ? 1 : 0
  api_update_antivirus_queue = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:tdr-api-update-antivirus-${local.environment}"
}