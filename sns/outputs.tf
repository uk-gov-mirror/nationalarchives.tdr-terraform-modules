output "sns_arn" {
  value = aws_sns_topic.log_aggregation.*.arn[0]
}