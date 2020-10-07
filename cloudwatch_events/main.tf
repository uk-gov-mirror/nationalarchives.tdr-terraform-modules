resource "aws_cloudwatch_event_rule" "ecr_image_scan" {
  name          = "ecr-image-scan"
  description   = "Capture each ECR Image Scan"
  event_pattern = templatefile("${path.module}/templates/${var.event_pattern}_pattern.json.tpl", {})
}

resource "aws_cloudwatch_event_target" "sqs_event_target" {
  count = local.count_sqs_event_target
  rule = aws_cloudwatch_event_rule.ecr_image_scan.name
  arn  = var.log_group_event_target_arn
}

resource "aws_cloudwatch_event_target" "lambda_event_target" {
  count = local.count_lambda_event_target
  rule = aws_cloudwatch_event_rule.ecr_image_scan.name
  arn  = var.lambda_event_target_arn[count.index]
}
