resource "aws_sqs_queue" "sqs_queue" {
  count = var.apply_resource == true ? 1 : 0
  name  = local.sqs_name

  tags = merge(
    var.common_tags,
    map(
      "Name", local.sqs_name,
    )
  )
}

resource "aws_sns_topic_subscription" "sqs_topic_subscription" {
  for_each  = toset(local.sns_topic_arns)
  topic_arn = each.key
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_queue.*.arn[0]
}