resource "aws_lambda_function" "lambda_api_update_function" {
  count         = local.count_api_update_av
  function_name = "${var.project}-api-update-antivirus-${local.environment}"
  handler       = "uk.gov.nationalarchives.api.update.antivirus.AntivirusUpdate::update"
  role          = aws_iam_role.lambda_api_update_iam_role.*.arn[0]
  runtime       = "java8"
  s3_bucket     = "tdr-backend-checks-${local.environment}"
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
    }
  }
}

data "aws_ssm_parameter" "keycloak_backend_checks_client_secret" {
  name = "/${local.environment}/keycloak/backend_checks_client/secret"
}

resource "aws_lambda_function_event_invoke_config" "lambda_api_update_async_config" {
  count         = local.count_api_update_av
  function_name = aws_lambda_function.lambda_api_update_function.*.function_name[0]
  destination_config {
    on_failure {
      destination = aws_sqs_queue.lambda_api_update_failure_queue.*.arn[0]
    }
  }
  maximum_retry_attempts = 2
}

resource "aws_lambda_event_source_mapping" "api_update_av_sqs_queue_mapping" {
  count            = local.count_api_update_av
  event_source_arn = local.api_update_antivirus_queue
  function_name    = aws_lambda_function.lambda_api_update_function.*.arn[0]
  // The mapping is updated to point to a new lambda version each time the lambda is deployed. This prevents terraform from resetting it when it runs.
  lifecycle {
    ignore_changes = [function_name]
  }
}

resource "aws_sqs_queue" "lambda_api_update_failure_queue" {
  count = local.count_api_update_av
  name  = "backend-check-failure-queue-api-update-av"

}

resource "aws_cloudwatch_log_group" "lambda_api_update_log_group" {
  count = local.count_api_update_av
  name  = "/aws/lambda/${aws_lambda_function.lambda_api_update_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "lambda_api_update_policy" {
  count  = local.count_api_update_av
  policy = templatefile("${path.module}/templates/api_update.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, sqs_arn = aws_sqs_queue.lambda_api_update_failure_queue.*.arn[0], input_sqs_arn = local.api_update_antivirus_queue })
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