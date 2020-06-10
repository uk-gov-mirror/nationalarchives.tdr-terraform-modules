resource "aws_sqs_queue" "sqs_queue" {
  count  = var.apply_resource == true ? 1 : 0
  name   = local.sqs_name
  policy = templatefile("./tdr-terraform-modules/sqs/templates/${var.sqs_policy}_policy.json.tpl", { region = var.region, environment = local.environment, account_id = data.aws_caller_identity.current.account_id, sqs_name = local.sqs_name })
  redrive_policy = length(var.dead_letter_queues) > 0 ? jsonencode({
    deadLetterTargetArn = var.dead_letter_queues[0]
    maxReceiveCount = 3
  }) : null
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