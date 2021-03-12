resource "aws_lambda_function" "notifications_lambda_function" {
  count         = local.count_notifications
  function_name = "${var.project}-notifications-${local.environment}"
  handler       = "uk.gov.nationalarchives.notifications.Lambda::process"
  role          = aws_iam_role.notifications_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/notifications.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webook[count.index].value
      TO_EMAIL      = "${data.aws_ssm_parameter.notification_email_prefix[count.index].value}@nationalarchives.gov.uk"
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

data aws_ssm_parameter "notification_email_prefix" {
  count = local.count_notifications
  name  = "/${local.environment}/notification/email/prefix"
}

data aws_ssm_parameter "slack_webook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/notification/webhook"
}

resource "aws_cloudwatch_log_group" "notifications_lambda_log_group" {
  count = local.count_notifications
  name  = "/aws/lambda/${aws_lambda_function.notifications_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "notifications_lambda_policy" {
  count  = local.count_notifications
  policy = templatefile("${path.module}/templates/notifications_lambda.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment, email = "${data.aws_ssm_parameter.notification_email_prefix[count.index].value}@nationalarchives.gov.uk" })
  name   = "${upper(var.project)}NotificationsLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "notifications_lambda_iam_role" {
  count              = local.count_notifications
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}NotificationsLambdaRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "notifications_lambda_role_policy" {
  count      = local.count_notifications
  policy_arn = aws_iam_policy.notifications_lambda_policy.*.arn[0]
  role       = aws_iam_role.notifications_lambda_iam_role.*.name[0]
}

resource "aws_lambda_permission" "lambda_permissions" {
  for_each      = var.event_rule_arns
  statement_id  = "AllowExecutionFromEvents${split("/", each.key)[1]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda_function.*.arn[0]
  principal     = "events.amazonaws.com"
  source_arn    = each.value
}

resource "aws_lambda_permission" "lambda_permissions_sns" {
  for_each      = var.sns_topic_arns
  statement_id  = "AllowExecutionFromSNS${split(":", each.key)[5]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda_function.*.arn[0]
  principal     = "sns.amazonaws.com"
  source_arn    = each.value
}

resource "aws_sns_topic_subscription" "intg_topic_subscription" {
  count     = local.count_notifications
  endpoint  = aws_lambda_function.notifications_lambda_function.*.arn[count.index]
  protocol  = "lambda"
  topic_arn = "arn:aws:sns:eu-west-2:${data.aws_ssm_parameter.intg_account_number.*.value[count.index]}:tdr-notifications-intg"
}

resource "aws_sns_topic_subscription" "staging_topic_subscription" {
  count     = local.count_notifications
  endpoint  = aws_lambda_function.notifications_lambda_function.*.arn[count.index]
  protocol  = "lambda"
  topic_arn = "arn:aws:sns:eu-west-2:${data.aws_ssm_parameter.staging_account_number.*.value[count.index]}:tdr-notifications-staging"
}
// Need to add a prod subscription when it exists