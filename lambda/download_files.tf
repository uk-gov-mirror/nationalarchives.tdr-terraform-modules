resource "aws_lambda_function" "download_files_lambda_function" {
  count         = local.count_download_files
  function_name = local.download_files_function_name
  handler       = "uk.gov.nationalarchives.downloadfiles.Lambda::process"
  role          = aws_iam_role.download_files_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/download-files.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      ENVIRONMENT       = aws_kms_ciphertext.environment_vars_download_files["environment"].ciphertext_blob
      INPUT_QUEUE       = aws_kms_ciphertext.environment_vars_download_files["input_queue"].ciphertext_blob
      ANTIVIRUS_QUEUE   = aws_kms_ciphertext.environment_vars_download_files["antivirus_queue"].ciphertext_blob
      FILE_FORMAT_QUEUE = aws_kms_ciphertext.environment_vars_download_files["file_format_queue"].ciphertext_blob
      CHECKSUM_QUEUE    = aws_kms_ciphertext.environment_vars_download_files["checksum_queue"].ciphertext_blob
      AUTH_URL          = aws_kms_ciphertext.environment_vars_download_files["auth_url"].ciphertext_blob
      API_URL           = aws_kms_ciphertext.environment_vars_download_files["api_url"].ciphertext_blob
      CLIENT_ID         = aws_kms_ciphertext.environment_vars_download_files["client_id"].ciphertext_blob
      CLIENT_SECRET     = aws_kms_ciphertext.environment_vars_download_files["client_secret"].ciphertext_blob
      ROOT_DIRECTORY    = aws_kms_ciphertext.environment_vars_download_files["root_directory"].ciphertext_blob
    }
  }
  file_system_config {
    # EFS file system access point ARN
    arn              = var.backend_checks_efs_access_point.arn
    local_mount_path = var.backend_checks_efs_root_directory_path
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.allow_efs_lambda_download_files.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_download_files" {
  for_each  = local.count_download_files == 0 ? {} : { environment = local.environment, input_queue = local.download_files_queue_url, antivirus_queue = local.antivirus_queue_url, file_format_queue = local.file_format_queue_url, checksum_queue = local.checksum_queue_url, auth_url = var.auth_url, api_url = "${var.api_url}/graphql", client_id = "tdr-backend-checks", client_secret = var.backend_checks_client_secret, root_directory = var.backend_checks_efs_root_directory_path }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.download_files_function_name }
}

resource "aws_lambda_event_source_mapping" "download_files_sqs_queue_mapping" {
  count            = local.count_download_files
  event_source_arn = local.download_files_queue
  function_name    = aws_lambda_function.download_files_lambda_function.*.arn[0]
  batch_size       = 1
}

resource "aws_cloudwatch_log_group" "download_files_lambda_log_group" {
  count = local.count_download_files
  name  = "/aws/lambda/${aws_lambda_function.download_files_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "download_files_lambda_policy" {
  count  = local.count_download_files
  policy = templatefile("${path.module}/templates/download_files_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, antivirus_queue = local.antivirus_queue, checksum_queue = local.checksum_queue, file_format_queue = local.file_format_queue, download_files_queue = local.download_files_queue, file_system_id = var.file_system_id, kms_arn = var.kms_key_arn })
  name   = "${upper(var.project)}DownloadFilesPolicy"
}

resource "aws_iam_role" "download_files_lambda_iam_role" {
  count              = local.count_download_files
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}DownloadFilesRole"
}

resource "aws_iam_role_policy_attachment" "download_files_lambda_role_policy" {
  count      = local.count_download_files
  policy_arn = aws_iam_policy.download_files_lambda_policy.*.arn[0]
  role       = aws_iam_role.download_files_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "allow_efs_lambda_download_files" {
  count       = local.count_download_files
  name        = "allow-efs-download-files"
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
    map("Name", "${var.project}-lambda-allow-efs-download-files")
  )
}
