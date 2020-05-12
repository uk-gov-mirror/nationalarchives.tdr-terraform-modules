resource "aws_sqs_queue" "sqs_queue" {
  name = local.sqs_name

  tags = merge(
    var.common_tags,
    map(
      "Name", local.sqs_name,
    )
  )
}