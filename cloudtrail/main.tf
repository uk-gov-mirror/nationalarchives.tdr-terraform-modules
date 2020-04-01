data "template_file" "cloudtrail_assume_role_policy" {
  template = file("./tdr-terraform-modules/cloudtrail/templates/assume_role_policy.json.tpl")
}

resource "aws_iam_role" "cloudtrail_role" {
  name               = "${upper(var.project)}CloudTrail${title(local.environment)}"
  assume_role_policy = data.template_file.cloudtrail_assume_role_policy.rendered
}

data "template_file" "cloudwatch_policy" {
  template = file("./tdr-terraform-modules/cloudtrail/templates/cloudwatch_logs_policy.json.tpl")
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name   = "${upper(var.project)}Cloudwatch${title(local.environment)}"
  policy = data.template_file.cloudwatch_policy.rendered
}

resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attach" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "/cloudtrail/${local.cloudtrail_prefix}"
  tags = var.common_tags
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = local.cloudtrail_name
  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = local.cloudtrail_prefix
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail.arn
  tags                          = var.common_tags
}
