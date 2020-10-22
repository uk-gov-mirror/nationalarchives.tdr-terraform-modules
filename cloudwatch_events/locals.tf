locals {
  count_sqs_event_target    = var.log_group_event_target_arn == "" ? 0 : 1
  count_lambda_event_target = var.lambda_event_target_arn == "" ? 0 : 1
  count_event_pattern       = var.event_pattern == "" ? 0 : 1
  count_event_schedule      = var.schedule == "" ? 0 : 1
  event_rule_name           = length(aws_cloudwatch_event_rule.event_rule_event_pattern) == 0 ? aws_cloudwatch_event_rule.event_rule_event_schedule[0].name : aws_cloudwatch_event_rule.event_rule_event_pattern[0].name
  event_rule_arn            = length(aws_cloudwatch_event_rule.event_rule_event_pattern) == 0 ? aws_cloudwatch_event_rule.event_rule_event_schedule[0].arn : aws_cloudwatch_event_rule.event_rule_event_pattern[0].arn
}
