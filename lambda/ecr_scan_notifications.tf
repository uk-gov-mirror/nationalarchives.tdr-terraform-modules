resource "aws_lambda_function" "ecr_scan_notifications_lambda_function" {
  count         = local.count_ecr_scan_notifications
  function_name = "${var.project}-ecr-scan-notifications-${local.environment}"
  handler       = "uk.gov.nationalarchives.scannotifications.Lambda::process"
  role          = aws_iam_role.ecr_scan_notifications_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/scan-notifications.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      SLACK_WEBHOOK = data.aws_ssm_parameter.ecr_notification_slack_webook[count.index].value
      TO_EMAIL      = "aws_tdr_management@nationalarchives.gov.uk"
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

data aws_ssm_parameter "ecr_notification_slack_webook" {
  count = local.count_ecr_scan_notifications
  name  = "/${local.environment}/slack/ecr/webhook"
}

resource "aws_cloudwatch_log_group" "ecr_scan_notifications_lambda_log_group" {
  count = local.count_ecr_scan_notifications
  name  = "/aws/lambda/${aws_lambda_function.ecr_scan_notifications_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "ecr_scan_notifications_lambda_policy" {
  count  = local.count_ecr_scan_notifications
  policy = templatefile("${path.module}/templates/ecr_scan_notifications_lambda.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment })
  name   = "${upper(var.project)}EcrScanNotificationsLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "ecr_scan_notifications_lambda_iam_role" {
  count              = local.count_ecr_scan_notifications
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}EcrScanNotificationsLambdaRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "ecr_scan_notifications_lambda_role_policy" {
  count      = local.count_ecr_scan_notifications
  policy_arn = aws_iam_policy.ecr_scan_notifications_lambda_policy.*.arn[0]
  role       = aws_iam_role.ecr_scan_notifications_lambda_iam_role.*.name[0]
}

resource "aws_lambda_permission" "lambda_permissions" {
  for_each      = var.event_rule_arns
  statement_id  = "AllowExecutionFromEvents${split("/", each.key)[1]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecr_scan_notifications_lambda_function.*.arn[0]
  principal     = "events.amazonaws.com"
  source_arn    = each.value
}
