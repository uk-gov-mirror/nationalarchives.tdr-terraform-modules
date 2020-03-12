resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "${var.project}-${local.environment}-${local.region}"
  role_arn = local.region == var.primary_region ? aws_iam_role.config_role.*.arn[0] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${upper(var.project)}Config${title(var.environment_full_name)}"

  recording_group {
    all_supported                 = var.all_supported
    include_global_resource_types = var.include_global_resource_types
  }
}

data "template_file" "config_assume_role_policy" {
  template = file("./tdr-terraform-modules/config/templates/config_assume_role_policy.json.tpl")
}

resource "aws_iam_role" "config_role" {
  count              = local.region == var.primary_region ? 1 : 0
  name               = "${upper(var.project)}Config${title(var.environment_full_name)}"
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
  name        = "${var.project}-config-${local.environment}"
  description = "Allows access to AWS Config S3 bucket"
  policy      = data.template_file.s3_access_policy.rendered
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  count      = local.region == var.primary_region ? 1 : 0
  role       = aws_iam_role.config_role.*.name[0]
  policy_arn = aws_iam_policy.s3_access_policy.*.arn[0]
}

resource "aws_iam_role_policy_attachment" "config_policy_attach" {
  count      = local.region == var.primary_region ? 1 : 0
  role       = aws_iam_role.config_role.*.name[0]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_config_delivery_channel" "config_channel" {
  name           = "${var.project}-config-${local.environment}"
  s3_bucket_name = var.bucket_id
  s3_key_prefix  = data.aws_region.current.name
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