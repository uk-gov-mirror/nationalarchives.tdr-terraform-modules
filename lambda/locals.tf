locals {
  workspace                              = lower(terraform.workspace)
  environment                            = local.workspace == "default" ? "mgmt" : local.workspace
  count_log_data                         = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  count_notifications                    = var.apply_resource == true && var.lambda_ecr_scan_notifications == true ? 1 : 0
  count_ecr_scan                         = var.apply_resource == true && var.lambda_ecr_scan == true ? 1 : 0
  count_rotate_keycloak_secrets          = var.apply_resource == true && var.lambda_rotate_keycloak_secrets == true ? 1 : 0
  count_signed_cookies                   = var.apply_resource == true && var.lambda_signed_cookies == true ? 1 : 0
  count_export_status_update             = var.apply_resource == true && var.lambda_export_status_update == true ? 1 : 0
  count_reporting                        = var.apply_resource == true && var.lambda_reporting == true ? 1 : 0
  count_create_db_users                  = var.apply_resource == true && var.lambda_create_db_users ? 1 : 0
  count_export_api_authoriser            = var.apply_resource == true && var.lambda_export_authoriser == true ? 1 : 0
  count_service_unavailable              = var.apply_resource == true && var.lambda_service_unavailable == true ? 1 : 0
  count_create_keycloak_users_api        = var.apply_resource == true && var.lambda_create_keycloak_user_api == true ? 1 : 0
  count_create_keycloak_users_s3         = var.apply_resource == true && var.lambda_create_keycloak_user_s3 == true ? 1 : 0
  create_db_users_function_name          = "${var.project}-${var.lambda_name}-${local.environment}"
  create_keycloak_user_api_function_name = "${var.project}-create-keycloak-user-api-${local.environment}"
  create_keycloak_user_s3_function_name  = "${var.project}-create-keycloak-user-s3-${local.environment}"
  export_api_authoriser_function_name    = "${var.project}-export-api-authoriser-${local.environment}"
  export_status_update_function_name     = "${var.project}-export-status-update-${local.environment}"
  log_data_function_name                 = "${var.project}-log-data-${local.environment}"
  notifications_function_name            = "${var.project}-notifications-${local.environment}"
  signed_cookies_function_name           = "${var.project}-signed-cookies-${local.environment}"
  reporting_function_name                = "${var.project}-reporting-${local.environment}"
  rotate_keycloak_secrets_function_name  = "${var.project}-rotate-keycloak-secrets-${local.environment}"
  service_unavailable_function_name      = "${var.project}-service-unavailable-${local.environment}"
  export_api_authoriser_arn              = var.apply_resource == true && var.lambda_export_authoriser == true && length(aws_lambda_function.export_api_authoriser_lambda_function) > 0 ? aws_lambda_function.export_api_authoriser_lambda_function.*.arn[0] : ""
  signed_cookies_arn                     = var.apply_resource == true && var.lambda_signed_cookies == true && length(aws_lambda_function.signed_cookies_lambda_function) > 0 ? aws_lambda_function.signed_cookies_lambda_function.*.arn[0] : ""
  create_keycloak_user_api_arn           = var.apply_resource == true && var.lambda_create_keycloak_user_api == true && length(aws_lambda_function.create_keycloak_users_api_lambda_function) > 0 ? aws_lambda_function.create_keycloak_users_api_lambda_function.*.arn[0] : ""
  create_keycloak_user_s3_arn            = var.apply_resource == true && var.lambda_create_keycloak_user_s3 == true && length(aws_lambda_function.create_keycloak_users_s3_lambda_function) > 0 ? aws_lambda_function.create_keycloak_users_s3_lambda_function.*.arn[0] : ""
  principal_arns                         = setunion(var.sns_topic_arns, var.sqs_queue_arns)
  slack_tdr_webhook                      = "/${local.environment}/slack/notification/webhook"
  slack_judgment_webhook                 = "/${local.environment}/slack/judgment/webhook"
  slack_standard_webhook                 = "/${local.environment}/slack/standard/webhook"
  slack_notifications_webhook            = "/${local.environment}/slack/notifications/webhook"
  slack_export_webhook                   = "/${local.environment}/slack/export/webhook"
  slack_bau_webhook                      = "/${local.environment}/slack/bau/webhook"
  slack_transfers_webhook                = "/${local.environment}/slack/transfers/webhook"
  slack_releases_webhook                 = "/${local.environment}/release/slack/webhook"
  slack_dev_notifications_webhook        = "/${local.environment}/slack/dev_notifications/webhook"
}
