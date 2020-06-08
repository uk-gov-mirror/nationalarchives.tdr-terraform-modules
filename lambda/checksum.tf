resource "aws_lambda_function" "checksum_lambda_function" {
  count         = local.count_checksum
  function_name = "${var.project}-checksum-${local.environment}"
  handler       = "uk.gov.nationalarchives.checksum.ChecksumCalculator::update"
  role          = aws_iam_role.checksum_lambda_iam_role.*.arn[0]
  runtime       = "java8"
  filename       = "${path.module}/functions/checksum.jar"
  timeout       = 20
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      ENVIRONMENT = local.environment
      INPUT_QUEUE = local.checksum_queue_url
      OUTPUT_QUEUE = local.api_update_checksum_queue_url
      CHUNK_SIZE_IN_MB = 50
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "checksum_lambda_async_config" {
  count         = local.count_checksum
  function_name = aws_lambda_function.checksum_lambda_function.*.function_name[0]
  destination_config {
    on_failure {
      destination = aws_sqs_queue.checksum_lambda_failure_queue.*.arn[0]
    }
  }
  maximum_retry_attempts = 2
}

resource "aws_sqs_queue" "checksum_lambda_failure_queue" {
  count = local.count_checksum
  name  = "checksum-failure-queue"
}

resource "aws_lambda_event_source_mapping" "checksum_sqs_queue_mapping" {
  count            = local.count_checksum
  event_source_arn = local.checksum_queue
  function_name    = aws_lambda_function.checksum_lambda_function.*.arn[0]
}

resource "aws_cloudwatch_log_group" "checksum_lambda_log_group" {
  count = local.count_checksum
  name  = "/aws/lambda/${aws_lambda_function.checksum_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "checksum_lambda_policy" {
  count  = local.count_checksum
  policy = templatefile("${path.module}/templates/checksum_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, update_queue = local.api_update_checksum_queue, input_sqs_queue = local.checksum_queue, sqs_arn = aws_sqs_queue.checksum_lambda_failure_queue.*.arn[0] })
  name   = "${upper(var.project)}ChecksumPolicy"
}

resource "aws_iam_role" "checksum_lambda_iam_role" {
  count              = local.count_checksum
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}ChecksumRole"
}

resource "aws_iam_role_policy_attachment" "checksum_lambda_role_policy" {
  count      = local.count_checksum
  policy_arn = aws_iam_policy.checksum_lambda_policy.*.arn[0]
  role       = aws_iam_role.checksum_lambda_iam_role.*.name[0]
}