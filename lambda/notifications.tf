locals {
  //management account does not need the notifications digital archiving event bus aws resources
  da_event_bus_count                 = var.apply_resource == true && local.environment != "mgmt" ? local.count_notifications : 0
  kms_export_bucket_encryption_count = var.apply_resource == true && local.environment != "mgmt" ? local.count_notifications : 0
}

resource "aws_lambda_function" "notifications_lambda_function" {
  count                          = local.count_notifications
  function_name                  = local.notifications_function_name
  handler                        = "uk.gov.nationalarchives.notifications.Lambda::process"
  role                           = aws_iam_role.notifications_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/notifications.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      SLACK_WEBHOOK                    = local.slack_notifications_webhook
      SLACK_JUDGMENT_WEBHOOK           = local.slack_judgment_webhook
      SLACK_STANDARD_WEBHOOK           = local.slack_standard_webhook
      SLACK_TDR_WEBHOOK                = local.slack_tdr_webhook
      SLACK_EXPORT_WEBHOOK             = local.slack_export_webhook
      SLACK_BAU_WEBHOOK                = local.slack_bau_webhook
      SLACK_TRANSFERS_WEBHOOK          = local.slack_transfers_webhook
      SLACK_RELEASES_WEBHOOK           = local.slack_releases_webhook
      SLACK_DEV_NOTIFICATIONS_WEBHOOK  = local.slack_dev_notifications_webhook
      SLACK_ADMIN_ACTION_ALERT_WEBHOOK = local.slack_admin_action_alert_webhook
      TO_EMAIL                         = aws_kms_ciphertext.environment_vars_notifications["to_email"].ciphertext_blob
      DA_EVENT_BUS                     = aws_kms_ciphertext.environment_vars_notifications["da_event_bus"].ciphertext_blob
      GOV_UK_NOTIFY_API_KEY            = aws_kms_ciphertext.environment_vars_notifications["gov_uk_notify_api_key"].ciphertext_blob
      SEND_GOV_UK_NOTIFICATIONS        = aws_kms_ciphertext.environment_vars_notifications["send_gov_uk_notifications"].ciphertext_blob
      TDR_INBOX_EMAIL                  = aws_kms_ciphertext.environment_vars_notifications["tdr_inbox_email"].ciphertext_blob
      ENVIRONMENT                      = local.environment
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }

  vpc_config {
    security_group_ids = var.notifications_vpc_config.security_group_ids
    subnet_ids         = var.notifications_vpc_config.subnet_ids
  }
}

resource "aws_kms_ciphertext" "environment_vars_notifications" {
  for_each = local.count_notifications == 0 ? {} : {
    to_email                  = "tdr-secops@nationalarchives.gov.uk",
    da_event_bus              = var.da_event_bus_arn
    gov_uk_notify_api_key     = data.aws_ssm_parameter.gov_uk_notify_api_key[0].value
    send_gov_uk_notifications = local.environment == "prod"
    tdr_inbox_email           = local.environment == "prod" ? "tdr@nationalarchives.gov.uk" : "tdrtest@nationalarchives.gov.uk"
  }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.notifications_function_name }
}

data "aws_ssm_parameter" "gov_uk_notify_api_key" {
  count = local.count_notifications
  name  = "/${local.environment}/keycloak/govuk_notify/api_key"
}

resource "aws_cloudwatch_log_group" "notifications_lambda_log_group" {
  count             = local.count_notifications
  name              = "/aws/lambda/${aws_lambda_function.notifications_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_policy" "notifications_lambda_policy" {
  count = local.count_notifications
  policy = templatefile("${path.module}/templates/notifications_lambda.json.tpl", {
    account_id  = data.aws_caller_identity.current.account_id,
    environment = local.environment,
    email       = "tdr-secops@nationalarchives.gov.uk",
    kms_arn     = var.kms_key_arn,
    parameter_names = jsonencode([
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_notifications_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_judgment_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_standard_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_tdr_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_export_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_bau_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_transfers_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_releases_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_dev_notifications_webhook}",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.slack_admin_action_alert_webhook}"
    ])
  })
  name = "${upper(var.project)}NotificationsLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_policy" "notifications_kms_bucket_key_policy" {
  count = local.kms_export_bucket_encryption_count
  policy = templatefile("${path.module}/templates/notifications_lambda_kms_bucket_key_policy.json.tpl", {
    kms_export_bucket_key_arn = var.kms_export_bucket_key_arn
  })
  name = "${upper(var.project)}NotificationsLambdaKMSBucketKeyPolicy${title(local.environment)}"
}

resource "aws_iam_policy" "da_event_bus_notifications_lambda_policy" {
  count = local.da_event_bus_count
  policy = templatefile("${path.module}/templates/notifications_lambda_da_event_bus_policy.json.tpl", {
    da_event_bus_arn         = var.da_event_bus_arn,
    da_event_bus_kms_key_arn = var.da_event_bus_kms_key_arn
  })
  name = "${upper(var.project)}NotificationsTransformEngineLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "notifications_lambda_iam_role" {
  count              = local.count_notifications
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  name               = "${upper(var.project)}NotificationsLambdaRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "notifications_lambda_role_policy" {
  count      = local.count_notifications
  policy_arn = aws_iam_policy.notifications_lambda_policy.*.arn[0]
  role       = aws_iam_role.notifications_lambda_iam_role.*.name[0]
}

resource "aws_iam_role_policy_attachment" "notifications_kms_bucket_key_policy" {
  count      = local.kms_export_bucket_encryption_count
  policy_arn = aws_iam_policy.notifications_kms_bucket_key_policy.*.arn[0]
  role       = aws_iam_role.notifications_lambda_iam_role.*.name[0]
}

resource "aws_iam_role_policy_attachment" "da_event_bus_notifications_policy" {
  count      = local.da_event_bus_count
  policy_arn = aws_iam_policy.da_event_bus_notifications_lambda_policy.*.arn[0]
  role       = aws_iam_role.notifications_lambda_iam_role.*.name[0]
}

resource "aws_lambda_permission" "lambda_permissions" {
  for_each      = nonsensitive(var.event_rule_arns)
  statement_id  = "AllowExecutionFromEvents${split("/", each.key)[1]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda_function.*.arn[0]
  principal     = "events.amazonaws.com"
  source_arn    = each.value
}

resource "aws_lambda_permission" "lambda_permissions_principals" {
  for_each      = local.principal_arns
  statement_id  = "AllowExecutionFrom${split(":", upper(each.key))[2]}${split(":", each.key)[5]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda_function.*.arn[0]
  principal     = "${split(":", (each.key))[2]}.amazonaws.com"
  source_arn    = each.value
}

resource "aws_sns_topic_subscription" "intg_topic_subscription" {
  for_each  = var.sns_topic_arns
  endpoint  = aws_lambda_function.notifications_lambda_function.*.arn[0]
  protocol  = "lambda"
  topic_arn = each.value
}

resource "aws_iam_policy" "vpc_access_policy" {
  count       = local.count_notifications
  policy      = templatefile("${path.module}/templates/lambda_vpc_policy.json.tpl", {})
  name        = "${local.notifications_function_name}-vpc-policy"
  description = "Allows access to the VPC for function ${local.notifications_function_name}"
}

resource "aws_iam_role_policy_attachment" "vpc_access_policy_attachment" {
  count      = local.count_notifications
  policy_arn = aws_iam_policy.vpc_access_policy[0].arn
  role       = aws_iam_role.notifications_lambda_iam_role[0].name
}
