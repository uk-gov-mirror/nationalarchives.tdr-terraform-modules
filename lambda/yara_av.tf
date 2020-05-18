resource "aws_lambda_function" "lambda_function" {
  count         = local.count_av_yara
  function_name = "${var.project}-yara-av-${local.environment}"
  handler       = "matcher.matcher_lambda_handler"
  role          = aws_iam_role.lambda_iam_role.*.arn[0]
  runtime       = "python3.7"
  s3_bucket     = "tdr-backend-checks-${local.environment}"
  s3_key        = "yara-av.zip"
  timeout       = 20
  memory_size   = 128
  tags          = var.common_tags
  environment {
    variables = {
      ENVIRONMENT = local.environment
      SQS_URL     = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/tdr-api-update-antivirus-${local.environment}"
    }
  }
}

resource "aws_sqs_queue" "lambda_failure_queue" {
  count = local.count_av_yara
  name  = "backend-check-failure-queue"

}

resource "aws_lambda_function_event_invoke_config" "lambda_async_config" {
  count         = local.count_av_yara
  function_name = aws_lambda_function.lambda_function.*.function_name[0]
  destination_config {
    on_failure {
      destination = aws_sqs_queue.lambda_failure_queue.*.arn[0]
    }
  }
  maximum_retry_attempts = 2
}

resource "aws_lambda_event_source_mapping" "av_sqs_queue_mapping" {
  count            = local.count_av_yara
  event_source_arn = local.antivirus_queue
  function_name    = aws_lambda_function.lambda_function.*.arn[0]
  // The mapping will be updated to point to a new lambda version each time the lambda is deployed. This prevents terraform from resetting it when it runs.
  lifecycle {
    ignore_changes = [function_name]
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count = local.count_av_yara
  name  = "/aws/lambda/${aws_lambda_function.lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "lambda_policy" {
  count  = local.count_av_yara
  policy = templatefile("${path.module}/templates/av_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, input_sqs_queue = local.antivirus_queue, sqs_arn = aws_sqs_queue.lambda_failure_queue.*.arn[0] })
  name   = "${upper(var.project)}YaraAvPolicy"
}

resource "aws_iam_role" "lambda_iam_role" {
  count              = local.count_av_yara
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}YaraAvRole"
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  count      = local.count_av_yara
  policy_arn = aws_iam_policy.lambda_policy.*.arn[0]
  role       = aws_iam_role.lambda_iam_role.*.name[0]
}