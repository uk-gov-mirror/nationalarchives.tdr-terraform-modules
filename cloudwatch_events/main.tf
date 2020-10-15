resource "aws_cloudwatch_event_rule" "event_rule" {
  name          = var.rule_name
  description   = var.rule_description
  event_pattern = templatefile("${path.module}/templates/${var.event_pattern}_pattern.json.tpl", var.event_variables)
}

resource "aws_cloudwatch_event_target" "sqs_event_target" {
  count = local.count_sqs_event_target
  rule  = aws_cloudwatch_event_rule.event_rule.name
  arn   = var.log_group_event_target_arn
}

resource "aws_cloudwatch_event_target" "lambda_event_target" {
  count = local.count_lambda_event_target
  rule  = aws_cloudwatch_event_rule.event_rule.name
  arn   = var.lambda_event_target_arn[count.index]
}
