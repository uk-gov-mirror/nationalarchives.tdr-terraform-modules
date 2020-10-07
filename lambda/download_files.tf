resource "aws_lambda_function" "download_files_lambda_function" {
  count         = local.count_download_files
  function_name = "${var.project}-download-files-${local.environment}"
  handler       = "uk.gov.nationalarchives.downloadfiles.Lambda::process"
  role          = aws_iam_role.download_files_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/download-files.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      ENVIRONMENT       = local.environment
      INPUT_QUEUE       = local.download_files_queue_url
      ANTIVIRUS_QUEUE   = local.antivirus_queue_url
      FILE_FORMAT_QUEUE = local.file_format_queue_url
      AUTH_URL          = var.auth_url
      API_URL           = "${var.api_url}/graphql"
      CLIENT_ID         = "tdr-backend-checks"
      CLIENT_SECRET     = data.aws_ssm_parameter.backend_checks_client_secret[0].value
      ROOT_DIRECTORY    = var.backend_checks_efs_root_directory_path
    }
  }
  file_system_config {
    # EFS file system access point ARN
    arn              = var.backend_checks_efs_access_point.arn
    local_mount_path = var.backend_checks_efs_root_directory_path
  }

  vpc_config {
    subnet_ids         = [data.aws_subnet.efs_private_subnet_zero.id, data.aws_subnet.efs_private_subnet_one.id]
    security_group_ids = aws_security_group.allow_efs_lambda_download_files.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
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
  policy = templatefile("${path.module}/templates/download_files_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, antivirus_queue = local.antivirus_queue, checksum_queue = local.checksum_queue, file_format_queue = local.file_format_queue, download_files_queue = local.download_files_queue, file_system_id = var.file_system_id })
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
  vpc_id      = data.aws_vpc.current.id

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
