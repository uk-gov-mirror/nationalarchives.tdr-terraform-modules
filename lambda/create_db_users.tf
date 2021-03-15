resource "aws_lambda_function" "create_db_users_lambda_function" {
  count         = local.count_create_db_users
  function_name = "${var.project}-create-db-users-${local.environment}"
  handler       = "uk.gov.nationalarchives.db.users.Lambda::process"
  role          = aws_iam_role.create_db_users_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/create-db-users.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      DB_ADMIN_USER     = var.db_admin_user
      DB_ADMIN_PASSWORD = var.db_admin_password
      DB_URL            = "jdbc:postgresql://${var.db_url}:5432/consignmentapi"
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.create_db_users_lambda.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_cloudwatch_log_group" "create_db_users_lambda_log_group" {
  count = local.count_create_db_users
  name  = "/aws/lambda/${aws_lambda_function.create_db_users_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "create_db_users_lambda_policy" {
  count  = local.count_create_db_users
  policy = templatefile("${path.module}/templates/create_db_users_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id })
  name   = "${upper(var.project)}CreateDbUsersPolicy${title(local.environment)}"
}

resource "aws_iam_role" "create_db_users_lambda_iam_role" {
  count              = local.count_create_db_users
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}CreateDbUsersRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "create_db_users_lambda_role_policy" {
  count      = local.count_create_db_users
  policy_arn = aws_iam_policy.create_db_users_lambda_policy.*.arn[0]
  role       = aws_iam_role.create_db_users_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "create_db_users_lambda" {
  count       = local.count_create_db_users
  name        = "create-db-users-lambda-security-group"
  description = "Allow access to the database"
  vpc_id      = var.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    map("Name", "${var.project}-create-db-users-lambda-security-group")
  )
}
