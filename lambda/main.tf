data "aws_caller_identity" "current" {}

locals {
  formatted_function = replace(title(replace(var.function, "-", " ")), " ", "")
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.project}-${var.function}-${var.environment}"
  handler       = var.handler
  role          = aws_iam_role.lambda_iam_role.arn
  runtime       = var.runtime
  s3_bucket     = "tdr-backend-checks-${var.environment}"
  s3_key        = "yara-av.zip"
  vpc_config {
    security_group_ids = [aws_security_group.lambda_security_group.id]
    subnet_ids         = var.lambda_subnets
  }
  timeout     = var.timeout
  memory_size = var.memory_size
  tags        = var.common_tags
  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
}

resource "aws_security_group" "lambda_security_group" {
  name   = "${var.function}-security-group"
  vpc_id = var.vpc_id
}

resource "aws_sqs_queue" "lambda_failure_queue" {
  name = "backend-check-failure-queue"
}

resource "aws_lambda_function_event_invoke_config" "lambda_async_config" {
  function_name = aws_lambda_function.lambda_function.function_name
  destination_config {
    on_failure {
      destination = aws_sqs_queue.lambda_failure_queue.arn
    }
  }
  maximum_retry_attempts = 2
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  tags = var.common_tags
}

resource "aws_iam_policy" "lambda_policy" {
  policy = templatefile("${path.module}/templates/${var.policy}.json.tpl", { environment = var.environment, account_id = data.aws_caller_identity.current.account_id, sqs_arn = aws_sqs_queue.lambda_failure_queue.arn })
  name   = "${upper(var.project)}${local.formatted_function}Policy"
}

data "aws_iam_policy_document" "lambda_assume_role_document" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_document.json
  name               = "${upper(var.project)}${local.formatted_function}Role"
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_iam_role.name
}