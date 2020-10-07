locals {
  count_sqs_event_target = var.log_group_event_target_arn == "" ? 0 : 1
  count_lambda_event_target = var.lambda_event_target_arn == "" ? 0 : 1
}