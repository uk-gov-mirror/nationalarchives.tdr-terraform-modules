resource "aws_lambda_function" "create_keycloak_db_user_lambda_function" {
  count         = local.count_create_keycloak_db_user
  function_name = local.create_keycloak_db_user_function_name
  handler       = "uk.gov.nationalarchives.db.users.Lambda::process"
  role          = aws_iam_role.create_keycloak_db_user_lambda_iam_role.*.arn[0]
  runtime       = "java11"
  filename      = "${path.module}/functions/create-db-users.jar"
  timeout       = 180
  memory_size   = 1024
  tags          = var.common_tags
  environment {
    variables = {
      DB_ADMIN_USER     = aws_kms_ciphertext.environment_vars_create_keycloak_db_user["db_admin_user"].ciphertext_blob
      DB_ADMIN_PASSWORD = aws_kms_ciphertext.environment_vars_create_keycloak_db_user["db_admin_password"].ciphertext_blob
      DB_URL            = aws_kms_ciphertext.environment_vars_create_keycloak_db_user["db_url"].ciphertext_blob
      DATABASE_NAME     = aws_kms_ciphertext.environment_vars_create_keycloak_db_user["database_name"].ciphertext_blob
      KEYCLOAK_PASSWORD = aws_kms_ciphertext.environment_vars_create_keycloak_db_user["keycloak_password"].ciphertext_blob
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.create_keycloak_db_user_lambda.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_create_keycloak_db_user" {
  for_each  = local.count_create_keycloak_db_user == 0 ? {} : { db_admin_user = var.db_admin_user, db_admin_password = var.db_admin_password, db_url = "jdbc:postgresql://${var.db_url}:5432/keycloak", database_name = "keycloak", keycloak_password = var.keycloak_password }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.create_keycloak_db_user_function_name }
}

resource "aws_cloudwatch_log_group" "create_keycloak_db_user_lambda_log_group" {
  count = local.count_create_keycloak_db_user
  name  = "/aws/lambda/${aws_lambda_function.create_keycloak_db_user_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "create_keycloak_db_user_lambda_policy" {
  count  = local.count_create_keycloak_db_user
  policy = templatefile("${path.module}/templates/create_keycloak_db_user_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, kms_arn = var.kms_key_arn })
  name   = "${upper(var.project)}CreateKeycloakDbUserPolicy${title(local.environment)}"
}

resource "aws_iam_role" "create_keycloak_db_user_lambda_iam_role" {
  count              = local.count_create_keycloak_db_user
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}CreateKeycloakDbUserRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "create_keycloak_db_user_lambda_role_policy" {
  count      = local.count_create_keycloak_db_user
  policy_arn = aws_iam_policy.create_keycloak_db_user_lambda_policy.*.arn[0]
  role       = aws_iam_role.create_keycloak_db_user_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "create_keycloak_db_user_lambda" {
  count       = local.count_create_keycloak_db_user
  name        = "create-keycloak-db-user-lambda-security-group"
  description = "Allow access to the keycloak database"
  vpc_id      = var.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    map("Name", "${var.project}-create-keycloak-db-users-lambda-security-group")
  )
}
