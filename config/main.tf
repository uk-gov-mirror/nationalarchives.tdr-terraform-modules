resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "example"
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

resource "aws_config_config_rule" "root_account_mfa_enabled" {
  count = local.region == var.primary_region ? 1 : 0
  name  = "root-account-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "root-account-mfa-enabled",
    )
  )

  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "restricted_ssh" {
  name = "restricted-ssh"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "restricted-ssh",
    )
  )

  depends_on = [aws_config_configuration_recorder.config_recorder]
}