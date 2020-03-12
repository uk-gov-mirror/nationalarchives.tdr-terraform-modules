output "config_recorder_id" {
  value = aws_config_configuration_recorder.config_recorder.id
}

output "config_topic_arn" {
  value = aws_sns_topic.config_topic.arn
}
