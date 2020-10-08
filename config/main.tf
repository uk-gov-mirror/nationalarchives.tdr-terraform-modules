resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "${var.project}-${local.environment}-${local.region}"
  role_arn = local.region == var.primary_region ? aws_iam_role.config_role.*.arn[0] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${upper(var.project)}Config${title(local.environment)}"

  recording_group {
    all_supported                 = var.all_supported
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "aws_sns_topic" "config_topic" {
  name  = "${var.project}-config-${local.environment}-${local.region}"
  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-config-${local.environment}",
    )
  )

}

data "template_file" "config_assume_role_policy" {
  template = file("./tdr-terraform-modules/config/templates/config_assume_role_policy.json.tpl")
}

resource "aws_iam_role" "config_role" {
  count              = local.region == var.primary_region ? 1 : 0
  name               = "${upper(var.project)}Config${title(local.environment)}"
  assume_role_policy = data.template_file.config_assume_role_policy.rendered
}

data "template_file" "s3_access_policy" {
  template = file("./tdr-terraform-modules/config/templates/s3_access_policy.json.tpl")
  vars = {
    bucket_name = var.bucket_id
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  count       = local.region == var.primary_region ? 1 : 0
  name        = "${upper(var.project)}Config${title(local.environment)}"
  description = "Allows access to AWS Config S3 bucket"
  policy      = data.template_file.s3_access_policy.rendered
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  count      = local.region == var.primary_region ? 1 : 0
  role       = aws_iam_role.config_role.*.name[0]
  policy_arn = aws_iam_policy.s3_access_policy.*.arn[0]
}

data "template_file" "sns_topic_access_policy" {
  template = file("./tdr-terraform-modules/config/templates/sns_topic_access_policy.json.tpl")
}

resource "aws_iam_policy" "sns_topic_access_policy" {
  count       = local.region == var.primary_region ? 1 : 0
  name        = "${upper(var.project)}SNSPublish${title(local.environment)}"
  description = "Allows pusblishing to SNS topic"
  policy      = data.template_file.sns_topic_access_policy.rendered
}

resource "aws_iam_role_policy_attachment" "sns_topic_policy_attach" {
  count      = local.region == var.primary_region ? 1 : 0
  role       = aws_iam_role.config_role.*.name[0]
  policy_arn = aws_iam_policy.sns_topic_access_policy.*.arn[0]
}

resource "aws_iam_role_policy_attachment" "config_policy_attach" {
  count      = local.region == var.primary_region ? 1 : 0
  role       = aws_iam_role.config_role.*.name[0]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "config_channel" {
  name           = "${var.project}-config-${local.environment}"
  s3_bucket_name = var.bucket_id
  s3_key_prefix  = data.aws_region.current.name
  sns_topic_arn  = aws_sns_topic.config_topic.arn
  depends_on     = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_configuration_recorder_status" "config_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_channel]
}

resource "aws_config_config_rule" "aws_managed_global_rule" {
  count = local.region == var.primary_region ? length(var.global_config_rule_list) : 0
  name  = lower(var.global_config_rule_list[count.index])

  source {
    owner             = "AWS"
    source_identifier = var.global_config_rule_list[count.index]
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", lower(var.global_config_rule_list[count.index]),
    )
  )

  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "aws_managed_regional_rule" {
  count = length(var.regional_config_rule_list)
  name  = lower(var.regional_config_rule_list[count.index])

  source {
    owner             = "AWS"
    source_identifier = var.regional_config_rule_list[count.index]
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", lower(var.regional_config_rule_list[count.index]),
    )
  )

  depends_on = [aws_config_configuration_recorder.config_recorder]
}

