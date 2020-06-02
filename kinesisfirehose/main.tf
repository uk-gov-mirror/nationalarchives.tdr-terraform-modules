resource "aws_iam_policy" "firehose_policy" {
  count  = var.apply_resource == true ? 1 : 0
  name   = "${upper(var.project)}KinesisFirehose${title(var.function)}${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/kinesisfirehose/templates/firehose_policy.json.tpl", { bucket = var.destination_bucket })
}

resource "aws_iam_role" "firehose_assume_role" {
  count              = var.apply_resource == true ? 1 : 0
  name               = "${upper(var.project)}KinesisFirehose${title(var.function)}${title(local.environment)}"
  assume_role_policy = templatefile("./tdr-terraform-modules/kinesisfirehose/templates/firehose_assume_role.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "log_data_base_policy_attach" {
  count      = var.apply_resource == true ? 1 : 0
  role       = aws_iam_role.firehose_assume_role.*.name[0]
  policy_arn = aws_iam_policy.firehose_policy.*.arn[0]
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  count       = var.apply_resource == true ? 1 : 0
  name        = local.stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_assume_role.*.arn[0]
    bucket_arn = local.destination_bucket_arn
    prefix     = "${var.log_type}/${local.environment}/${var.function}/"
  }
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  count  = var.apply_resource == true ? 1 : 0
  name   = "${upper(var.project)}CloudWatchLogsKinesis${title(var.function)}${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/kinesisfirehose/templates/cloudwatch_logs_policy.json.tpl", { kinesis_stream_arn = aws_kinesis_firehose_delivery_stream.extended_s3_stream.*.arn[0], cloudwatch_logs_role_arn = aws_iam_role.cloudwatch_logs_assume_role.*.arn[0] })
}

resource "aws_iam_role" "cloudwatch_logs_assume_role" {
  count              = var.apply_resource == true ? 1 : 0
  name               = "${upper(var.project)}CloudWatchLogsKinesis${title(var.function)}${title(local.environment)}"
  assume_role_policy = templatefile("./tdr-terraform-modules/kinesisfirehose/templates/cloudwatch_logs_assume_role.json.tpl", { aws_region = data.aws_region.current.name })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attach" {
  count      = var.apply_resource == true ? 1 : 0
  role       = aws_iam_role.cloudwatch_logs_assume_role.*.name[0]
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.*.arn[0]
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_subscription_filter" {
  name            = "${var.function}-firehose-${local.environment}"
  log_group_name  = var.cloudwatch_log_group_name
  role_arn        = aws_iam_role.cloudwatch_logs_assume_role.*.arn[0]
  filter_pattern  = "[]"
  destination_arn = aws_kinesis_firehose_delivery_stream.extended_s3_stream.*.arn[0]
  distribution    = "ByLogStream"
}
