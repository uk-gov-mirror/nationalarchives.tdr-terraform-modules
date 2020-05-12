resource "aws_iam_policy" "log_data_lambda_base_policy" {
  count  = local.count_log_data
  name   = "${upper(var.project)}LogDataLambdaBase${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/lambda/templates/lambda_base.json.tpl", {})
}

resource "aws_iam_role" "log_data_assume_role" {
  count              = local.count_log_data
  name               = "${upper(var.project)}LogDataAssumeRole${title(local.environment)}"
  assume_role_policy = templatefile("./tdr-terraform-modules/lambda/templates/lambda_assume_role.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "log_data_base_policy_attach" {
  count      = local.count_log_data
  role       = aws_iam_role.log_data_assume_role.*.name[0]
  policy_arn = aws_iam_policy.log_data_lambda_base_policy.*.arn[0]
}

resource "aws_iam_policy" "log_data_policy" {
  count  = local.count_log_data
  name   = "${upper(var.project)}LogData${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/lambda/templates/log_data.json.tpl", { mgmt_account_id = data.aws_ssm_parameter.mgmt_account_number.*.value[0] })
}

resource "aws_iam_role_policy_attachment" "log_data_policy_attach" {
  count      = local.count_log_data
  role       = aws_iam_role.log_data_assume_role.*.name[0]
  policy_arn = aws_iam_policy.log_data_policy.*.arn[0]
}

data "archive_file" "log_data_lambda" {
  type        = "zip"
  source_file = "./tdr-terraform-modules/lambda/functions/log-data/lambda_function.py"
  output_path = "/tmp/log-data-lambda.zip"
}

resource "aws_lambda_function" "log_data_lambda" {
  count            = local.count_log_data
  filename         = data.archive_file.log_data_lambda.output_path
  function_name    = "${var.project}-log-data-${local.environment}"
  description      = "Aggregate log data to a target S3 bucket"
  role             = aws_iam_role.log_data_assume_role.*.arn[0]
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.log_data_lambda.output_base64sha256
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
    ignore_changes = ["last_modified"]
  }
}

resource "aws_sns_topic_subscription" "log_data" {
  count     = local.count_log_data
  topic_arn = var.log_data_sns_topic
  protocol  = "lambda"
  endpoint  = aws_lambda_function.log_data_lambda.*.arn[0]
}

resource "aws_lambda_permission" "log_data" {
  count         = local.count_log_data
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_data_lambda.*.arn[0]
  principal     = "sns.amazonaws.com"
  source_arn    = var.log_data_sns_topic
}

resource "aws_iam_role" "log_data_cross_account_role" {
  count              = local.count_log_data_mgmt
  name               = "TDRLogDataCrossAccountRole${title(local.environment)}"
  description        = "Cross account role for Log Data lambda to the ${title(local.environment)} environment"
  assume_role_policy = templatefile("./tdr-terraform-modules/lambda/templates/log_data_cross_account_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, external_account_1 = data.aws_ssm_parameter.intg_account_number.*.value[0], external_account_2 = data.aws_ssm_parameter.staging_account_number.*.value[0], external_account_3 = data.aws_ssm_parameter.prod_account_number.*.value[0] })

  tags = merge(
    var.common_tags,
    map(
      "Name", "Log Data Cross Account Role",
    )
  )
}

resource "aws_iam_role_policy_attachment" "log_data_cross_account_policy_attach" {
  count      = local.count_log_data_mgmt
  role       = aws_iam_role.log_data_cross_account_role.*.name[0]
  policy_arn = aws_iam_policy.log_data_policy.*.arn[0]
}