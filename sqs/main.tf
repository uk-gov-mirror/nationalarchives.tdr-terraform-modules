resource "aws_sqs_queue" "sqs_queue" {
  name = local.sqs_name

  tags = merge(
    var.common_tags,
    map(
      "Name", local.sqs_name,
    )
  )
}

resource "aws_sns_topic_subscription" "sqs_topic_subscription" {
  for_each  = toset(var.sns_topic_arns)
  topic_arn = each.key
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_queue.arn
}