resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.api_name
  body = templatefile("${path.module}/templates/${var.api_template}.json.tpl", merge(var.template_params, { region = var.region, environment = var.environment, role_arn = aws_iam_role.rest_api_role.arn, title = title(var.api_name) }))
  tags = var.common_tags
}

resource "aws_api_gateway_account" "rest_api_account" {
  cloudwatch_role_arn = aws_iam_role.rest_api_cloudwatch_role.arn
}

resource "aws_iam_role" "rest_api_cloudwatch_role" {
  name               = "TDR${var.api_name}CloudwatchRole${title(var.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/api_gateway_assume_role.json.tpl", {})
}

resource "aws_iam_policy" "rest_api_cloudwatch_policy" {
  name   = "TDR${var.api_name}CloudwatchPolicy${title(var.environment)}"
  policy = templatefile("${path.module}/templates/api_cloudwatch_policy.json.tpl", { log_group_arn = aws_cloudwatch_log_group.rest_api_log_group.arn })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  policy_arn = aws_iam_policy.rest_api_cloudwatch_policy.arn
  role       = aws_iam_role.rest_api_cloudwatch_role.id
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = var.environment
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "rest_api_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.rest_api.id}/${var.environment}"
  retention_in_days = 7
}

resource "aws_iam_role" "rest_api_role" {
  name               = "TDR${var.api_name}Role${title(var.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/api_gateway_assume_role.json.tpl", {})
}

resource "aws_iam_policy" "rest_api_policy" {
  name   = "TDR${var.api_name}Policy${title(var.environment)}"
  policy = templatefile("${path.module}/templates/${var.api_template}_policy.json.tpl", merge({ account_id = data.aws_caller_identity.current.account_id }, var.template_params))
}

resource "aws_iam_role_policy_attachment" "rest_api_policy_attachment" {
  policy_arn = aws_iam_policy.rest_api_policy.arn
  role       = aws_iam_role.rest_api_role.name
}
