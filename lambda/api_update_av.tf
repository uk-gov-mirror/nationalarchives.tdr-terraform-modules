resource "aws_lambda_function" "lambda_api_update_function" {
  count         = local.count_api_update_av
  function_name = "${var.project}-api-update-antivirus-${local.environment}"
  handler       = "uk.gov.nationalarchives.api.update.antivirus.AntivirusUpdate::update"
  role          = aws_iam_role.lambda_api_update_iam_role.*.arn[0]
  runtime       = "java8"
  s3_bucket     = "tdr-backend-code-mgmt"
  s3_key        = "antivirus.jar"
  timeout       = 20
  memory_size   = 512
  tags          = var.common_tags
  environment {
    variables = {
      API_URL       = "${var.api_url}/graphql"
      AUTH_URL      = var.auth_url
      CLIENT_ID     = "tdr-backend-checks"
      CLIENT_SECRET = var.keycloak_backend_checks_client_secret
      QUEUE_URL     = local.api_update_antivirus_queue_url
    }
  }
}

resource "aws_lambda_event_source_mapping" "api_update_av_sqs_queue_mapping" {
  count            = local.count_api_update_av
  event_source_arn = local.api_update_antivirus_queue
  function_name    = aws_lambda_function.lambda_api_update_function.*.arn[0]
}

resource "aws_cloudwatch_log_group" "lambda_api_update_log_group" {
  count = local.count_api_update_av
  name  = "/aws/lambda/${aws_lambda_function.lambda_api_update_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "lambda_api_update_policy" {
  count  = local.count_api_update_av
  policy = templatefile("${path.module}/templates/api_update.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, input_sqs_arn = local.api_update_antivirus_queue })
  name   = "${upper(var.project)}ApiUpdateAvPolicy"
}

resource "aws_iam_role" "lambda_api_update_iam_role" {
  count              = local.count_api_update_av
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}ApiUpdateRole"
}

resource "aws_iam_role_policy_attachment" "lambda_api_update_role_policy" {
  count      = local.count_api_update_av
  policy_arn = aws_iam_policy.lambda_api_update_policy.*.arn[0]
  role       = aws_iam_role.lambda_api_update_iam_role.*.name[0]
}