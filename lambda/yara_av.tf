resource "aws_lambda_function" "lambda_function" {
  count         = local.count_av_yara
  function_name = local.yara_av_function_name
  handler       = "matcher.matcher_lambda_handler"
  role          = aws_iam_role.lambda_iam_role.*.arn[0]
  runtime       = "python3.7"
  filename      = "${path.module}/functions/yara-av.zip"
  timeout       = 180
  memory_size   = 3008
  tags          = var.common_tags
  environment {
    variables = {
      ENVIRONMENT    = local.environment
      ROOT_DIRECTORY = var.backend_checks_efs_root_directory_path
      INPUT_QUEUE    = local.antivirus_queue_url
      OUTPUT_QUEUE   = local.api_update_queue_url
    }
  }

  file_system_config {
    # EFS file system access point ARN
    arn              = var.backend_checks_efs_access_point.arn
    local_mount_path = var.backend_checks_efs_root_directory_path
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.allow_efs_lambda_av.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }

  depends_on = [var.mount_target_zero, var.mount_target_one]
}

data "aws_kms_ciphertext" "environment_vars_yara_av" {
  for_each  = local.count_av_yara == 0 ? {} : { environment = local.environment, root_directory = var.backend_checks_efs_root_directory_path, input_queue = local.antivirus_queue_url, output_queue = local.api_update_queue_url }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.yara_av_function_name }
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
  count = local.count_av_yara
  policy = templatefile(
    "${path.module}/templates/av_lambda.json.tpl",
    {
      environment     = local.environment,
      account_id      = data.aws_caller_identity.current.account_id,
      update_queue    = local.api_update_queue,
      input_sqs_queue = local.antivirus_queue,
      file_system_id  = var.file_system_id,
      kms_arn         = var.kms_key_arn
    }
  )
  name = "${upper(var.project)}YaraAvPolicy"
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

resource "aws_security_group" "allow_efs_lambda_av" {
  count       = local.count_av_yara
  name        = "allow-efs-lambda-antivirus"
  description = "Allow EFS inbound traffic"
  vpc_id      = var.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    map("Name", "${var.project}-lambda-allow-efs-av-files")
  )
}
