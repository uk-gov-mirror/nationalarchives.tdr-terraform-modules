resource "aws_iam_policy" "log_data_lambda_base_policy" {
  count  = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  name   = "${upper(var.project)}LogDataLambdaBase${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/lambda/templates/common/lambda_base_policy.json.tpl", {})
}

resource "aws_iam_role" "log_data_assume_role" {
  count              = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  name               = "${upper(var.project)}LogDataAssumeRole${title(local.environment)}"
  assume_role_policy = templatefile("./tdr-terraform-modules/lambda/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "log_data_base_policy_attach" {
  count      = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  role       = aws_iam_role.log_data_assume_role.*.name[0]
  policy_arn = aws_iam_policy.log_data_lambda_base_policy.*.arn[0]
}

resource "aws_iam_policy" "log_data_policy" {
  count  = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  name   = "${upper(var.project)}LogData${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/lambda/templates/custom/log_data_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "log_data_policy_attach" {
  count      = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  role       = aws_iam_role.log_data_assume_role.*.name[0]
  policy_arn = aws_iam_policy.log_data_policy.*.arn[0]
}

resource "aws_lambda_function" "log_data_lambda" {
  count            = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  filename         = "./tdr-terraform-modules/lambda/functions/log-data-Yu49chGwI34qPzJh.zip"
  function_name    = "${var.project}-log-data-${local.environment}"
  description      = "Aggregate log data to a target S3 bucket"
  role             = aws_iam_role.log_data_assume_role.*.arn[0]
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("./tdr-terraform-modules/lambda/functions/log-data-Yu49chGwI34qPzJh.zip")
  runtime          = "python3.7"
  timeout          = 30
  publish          = true

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-log-data-${local.environment}",
    )
  )

  environment {
    variables = {
      TARGET_S3_BUCKET = var.target_s3_bucket
    }
  }

  lifecycle {
    ignore_changes = [
      "filename",
      "last_modified",
    ]
  }
}

resource "aws_sns_topic_subscription" "log_data" {
  count     = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  topic_arn = var.log_data_sns_topic
  protocol  = "lambda"
  endpoint  = aws_lambda_function.log_data_lambda.*.arn[0]
}

resource "aws_lambda_permission" "log_data" {
  count         = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_data_lambda.*.arn[0]
  principal     = "sns.amazonaws.com"
  source_arn    = var.log_data_sns_topic
}
