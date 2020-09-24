resource "aws_cloudwatch_event_rule" "ecr_image_scan" {
  name        = "ecr-image-scan"
  description = "Capture each ECR Image Scan"
  event_pattern = templatefile("${path.module}/templates/${var.event_pattern}_pattern.json.tpl", {})
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.ecr_image_scan.name
  arn       = var.event_target_arn
}
