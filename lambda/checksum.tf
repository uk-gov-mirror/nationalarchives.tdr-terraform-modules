resource "aws_lambda_function" "checksum_lambda_function" {
  count         = local.count_checksum
  function_name = local.checksum_function_name
  handler       = "uk.gov.nationalarchives.checksum.Lambda::process"
  role          = aws_iam_role.checksum_lambda_iam_role.*.arn[0]
  runtime       = "java8"
  filename      = "${path.module}/functions/checksum.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      INPUT_QUEUE      = data.aws_kms_ciphertext.environment_vars_checksum["input_queue"].ciphertext_blob
      OUTPUT_QUEUE     = data.aws_kms_ciphertext.environment_vars_checksum["output_queue"].ciphertext_blob
      CHUNK_SIZE_IN_MB = data.aws_kms_ciphertext.environment_vars_checksum["chunk_size_in_mb"].ciphertext_blob
      ROOT_DIRECTORY   = data.aws_kms_ciphertext.environment_vars_checksum["root_directory"].ciphertext_blob
    }
  }

  file_system_config {
    # EFS file system access point ARN
    arn              = var.backend_checks_efs_access_point.arn
    local_mount_path = var.backend_checks_efs_root_directory_path
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.allow_efs_lambda_checksum.*.id
  }

  lifecycle {
    ignore_changes = [filename, environment]
  }

  depends_on = [var.mount_target_zero, var.mount_target_one]
}

data "aws_kms_ciphertext" "environment_vars_checksum" {
  for_each  = local.count_checksum == 0 ? {} : { input_queue = local.checksum_queue_url, output_queue = local.api_update_queue_url, chunk_size_in_mb = 50, root_directory = var.backend_checks_efs_root_directory_path }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.checksum_function_name }
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
  policy = templatefile("${path.module}/templates/checksum_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, update_queue = local.api_update_queue, input_sqs_queue = local.checksum_queue, file_system_id = var.file_system_id, kms_arn = var.kms_key_arn })
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

resource "aws_security_group" "allow_efs_lambda_checksum" {
  count       = local.count_checksum
  name        = "allow-efs-lambda-checksum"
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
    map("Name", "${var.project}-lambda-allow-efs-checksum-files")
  )
}
