resource "aws_lambda_function" "export_api_authoriser_lambda_function" {
  count         = local.count_export_api_authoriser
  function_name = local.export_api_authoriser_function_name
  handler       = "uk.gov.nationalarchives.consignmentexport.authoriser.Lambda::process"
  role          = aws_iam_role.export_api_authoriser_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/export-authoriser.jar"
  timeout       = 10
  memory_size   = 4096
  tags          = var.common_tags
  environment {
    variables = {
      API_URL = aws_kms_ciphertext.environment_vars_export_api_authoriser["api_url"].ciphertext_blob
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_export_api_authoriser" {
  for_each  = local.count_export_api_authoriser == 0 ? {} : { api_url = "${var.api_url}/graphql" }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.export_api_authoriser_function_name }
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

resource "aws_iam_policy" "export_authoriser_policy" {
  count  = local.count_export_api_authoriser
  name   = "${upper(var.project)}ExportApiAuthoriserLambdaPolicy${title(local.environment)}"
  policy = templatefile("${path.module}/templates/export_authoriser_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment, kms_arn = var.kms_key_arn })
}

resource "aws_iam_role_policy_attachment" "export_authoriser_attachment" {
  count      = local.count_export_api_authoriser
  policy_arn = aws_iam_policy.export_authoriser_policy[count.index].arn
  role       = aws_iam_role.export_api_authoriser_lambda_iam_role[count.index].id
}

resource "aws_lambda_permission" "export_api_lambda_permissions" {
  count         = local.count_export_api_authoriser
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.project}-export-api-authoriser-${local.environment}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_arn}/authorizers/*"
}
