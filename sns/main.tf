resource "aws_sns_topic" "sns_topic" {
  count  = var.apply_resource == true ? 1 : 0
  name   = local.sns_topic_name
  policy = templatefile("./tdr-terraform-modules/sns/templates/${var.sns_policy}.json.tpl", { region = var.region, account_id = data.aws_caller_identity.current.account_id, sns_topic_name = local.sns_topic_name, management_account = data.aws_ssm_parameter.mgmt_account_number.value })

  tags = merge(
    var.common_tags,
    map(
      "Name", local.sns_topic_name,
    )
  )
  kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
}
