resource "aws_lambda_function" "lambda_api_update_function" {
  count         = local.count_api_update
  function_name = "${var.project}-api-update-${local.environment}"
  handler       = "uk.gov.nationalarchives.api.update.Lambda::update"
  role          = aws_iam_role.lambda_api_update_iam_role.*.arn[0]
  runtime       = "java8"
  filename      = "${path.module}/functions/api-update.jar"
  timeout       = 20
  memory_size   = 512
  tags          = var.common_tags
  environment {
    variables = {
      API_URL       = "${var.api_url}/graphql"
      AUTH_URL      = var.auth_url
      CLIENT_ID     = "tdr-backend-checks"
      CLIENT_SECRET = var.keycloak_backend_checks_client_secret
      QUEUE_URL     = local.api_update_queue_url
    }
  }
  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_event_source_mapping" "api_update_sqs_queue_mapping" {
  count            = local.count_api_update
  event_source_arn = local.api_update_queue
  function_name    = aws_lambda_function.lambda_api_update_function.*.arn[0]
}

resource "aws_cloudwatch_log_group" "lambda_api_update_log_group" {
  count = local.count_api_update
  name  = "/aws/lambda/${aws_lambda_function.lambda_api_update_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "lambda_api_update_policy" {
  count  = local.count_api_update
  policy = templatefile("${path.module}/templates/api_update.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, input_sqs_arn = local.api_update_queue })
  name   = "${upper(var.project)}ApiUpdatePolicy"
}

resource "aws_iam_role" "lambda_api_update_iam_role" {
  count              = local.count_api_update
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}ApiUpdateRole"
}

resource "aws_iam_role_policy_attachment" "lambda_api_update_role_policy" {
  count      = local.count_api_update
  policy_arn = aws_iam_policy.lambda_api_update_policy.*.arn[0]
  role       = aws_iam_role.lambda_api_update_iam_role.*.name[0]
}

