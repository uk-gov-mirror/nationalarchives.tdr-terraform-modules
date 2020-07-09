resource "aws_lambda_function" "file_format_lambda_function" {
  count         = local.count_file_format
  function_name = "${var.project}-file-format-${local.environment}"
  handler       = "uk.gov.nationalarchives.fileformat.Lambda::process"
  role          = aws_iam_role.file_format_lambda_iam_role.*.arn[0]
  runtime       = "java8"
  filename      = "${path.module}/functions/file-format.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      ENVIRONMENT   = local.environment
      INPUT_QUEUE   = local.file_format_queue_url
      OUTPUT_QUEUE  = local.api_update_queue_url
      AUTH_URL      = var.auth_url
      API_URL       = var.api_url
      CLIENT_ID     = "tdr-backend-checks"
      CLIENT_SECRET = data.aws_ssm_parameter.backend_checks_client_secret[0].value
    }
  }
  file_system_config {
    # EFS file system access point ARN
    arn              = var.file_format_efs_access_point.arn
    local_mount_path = "/mnt/fileformat"
  }

  depends_on = [aws_efs_mount_target.target_az_zero, aws_efs_mount_target.target_az_one]

  vpc_config {
    subnet_ids         = aws_subnet.file_format_private.*.id
    security_group_ids = [aws_security_group.allow_efs_lambda[count.index].id]
  }
}

resource "aws_efs_mount_target" "target_az_zero" {
  count           = local.count_file_format
  file_system_id  = var.file_system.id
  subnet_id       = aws_subnet.file_format_private[0].id
  security_groups = [aws_security_group.mount_target_sg[0].id]
}

resource "aws_efs_mount_target" "target_az_one" {
  count           = local.count_file_format
  file_system_id  = var.file_system.id
  subnet_id       = aws_subnet.file_format_private[1].id
  security_groups = [aws_security_group.mount_target_sg[0].id]
}

resource "aws_security_group" "mount_target_sg" {
  count       = local.count_file_format
  name        = "mount-target-security-group"
  description = "Mount target security group"
  vpc_id      = data.aws_vpc.current.id

  ingress {
    description     = "EFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [data.aws_security_group.efs_group.id, aws_security_group.allow_efs_lambda[count.index].id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    map("Name", "mount-target-outbound-only")
  )
}

resource "aws_security_group" "allow_efs_lambda" {
  count       = local.count_file_format
  name        = "allow-efs"
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
    map("Name", "file-format-lambda-allow-efs")
  )
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
  policy = templatefile("${path.module}/templates/file_format_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, update_queue = local.api_update_queue, input_sqs_queue = local.file_format_queue, file_system_id = var.file_system.id })
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

resource "aws_subnet" "file_format_private" {
  count             = local.count_file_format_subnets
  cidr_block        = cidrsubnet(data.aws_vpc.current.cidr_block, 6, count.index + 4)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = data.aws_vpc.current.id

  tags = merge(
    var.common_tags,
    map("Name", "tdr-file-format-private-subnet-${count.index}-${local.environment}")
  )
}

resource "aws_route_table" "file_format_private" {
  count  = local.count_file_format_subnets
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = [data.aws_nat_gateway.main_zero.id, data.aws_nat_gateway.main_one.id][count.index]
  }

  tags = merge(
  var.common_tags,
  map("Name", "route-table-${count.index}-tdr-${local.environment}")
  )
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = local.count_file_format_subnets
  subnet_id      = aws_subnet.file_format_private.*.id[count.index]
  route_table_id = aws_route_table.file_format_private.*.id[count.index]
}