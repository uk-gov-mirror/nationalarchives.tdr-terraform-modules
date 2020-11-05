resource "aws_lambda_function" "export_api_authoriser_lambda_function" {
  count         = local.count_export_api_authoriser
  function_name = "${var.project}-export-api-authoriser-${local.environment}"
  handler       = "uk.gov.nationalarchives.exportauthoriser.Lambda::process"
  role          = aws_iam_role.export_api_authoriser_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/export-authoriser.jar"
  timeout       = 10
  memory_size   = 1024
  tags          = var.common_tags

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_cloudwatch_log_group" "export_api_authoriser_lambda_log_group" {
  count = local.count_export_api_authoriser
  name  = "/aws/lambda/${aws_lambda_function.export_api_authoriser_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_role" "export_api_authoriser_lambda_iam_role" {
  count              = local.count_export_api_authoriser
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}ExportApiAuthoriserLambdaRole${title(local.environment)}"
}

data "aws_api_gateway_rest_api" "export_rest_api" {
  count = local.count_export_api_authoriser
  name  = "ExportAPI"
}

resource "aws_lambda_permission" "export_api_lambda_permissions" {
  count         = local.count_export_api_authoriser
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.export_api_authoriser_lambda_function.*.arn[count.index]
  principal     = "apigateway.amazonaws.com"
  source_arn    = data.aws_api_gateway_rest_api.export_rest_api.*.arn[count.index]
}
