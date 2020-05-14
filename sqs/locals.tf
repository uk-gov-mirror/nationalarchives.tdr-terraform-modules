locals {
  workspace      = lower(terraform.workspace)
  environment    = local.workspace == "default" ? "mgmt" : local.workspace
  sqs_name       = "${var.project}-${var.function}-${local.environment}"
  sns_topic_arns = var.apply_resource == true ? var.sns_topic_arns : []
}

locals {
  sqs_arn = var.apply_resource == true ? aws_sqs_queue.sqs_queue.*.arn[0] : ""
}