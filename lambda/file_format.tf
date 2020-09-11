resource "aws_lambda_function" "file_format_lambda_function" {
  count         = local.count_file_format
  function_name = "${var.project}-file-format-${local.environment}"
  handler       = "uk.gov.nationalarchives.fileformat.Lambda::process"
  role          = aws_iam_role.file_format_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/file-format.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      ENVIRONMENT  = local.environment
      INPUT_QUEUE  = local.file_format_queue_url
      OUTPUT_QUEUE = local.api_update_queue_url
    }
  }
  file_system_config {
    # EFS file system access point ARN
    arn              = var.file_format_efs_access_point.arn
    local_mount_path = "/mnt/fileformat"
  }

  vpc_config {
    subnet_ids         = [data.aws_subnet.efs_private_subnet_zero.id, data.aws_subnet.efs_private_subnet_one.id]
    security_group_ids = [data.aws_security_group.efs_lambda_security_group.id]
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_event_source_mapping" "file_format_sqs_queue_mapping" {
  count            = local.count_file_format
  event_source_arn = local.file_format_queue
  function_name    = aws_lambda_function.file_format_lambda_function.*.arn[0]
}

resource "aws_cloudwatch_log_group" "file_format_lambda_log_group" {
  count = local.count_file_format
  name  = "/aws/lambda/${aws_lambda_function.file_format_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "file_format_lambda_policy" {
  count  = local.count_file_format
  policy = templatefile("${path.module}/templates/file_format_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, update_queue = local.api_update_queue, input_sqs_queue = local.file_format_queue, file_system_id = var.file_system_id })
  name   = "${upper(var.project)}FileFormatLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "file_format_lambda_iam_role" {
  count              = local.count_file_format
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}FileFormatRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "file_format_lambda_role_policy" {
  count      = local.count_file_format
  policy_arn = aws_iam_policy.file_format_lambda_policy.*.arn[0]
  role       = aws_iam_role.file_format_lambda_iam_role.*.name[0]
}