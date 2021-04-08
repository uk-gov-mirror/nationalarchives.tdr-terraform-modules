data "template_file" "key_policy" {
  template = file("./tdr-terraform-modules/kms/templates/${var.key_policy}.json.tpl")
  vars = {
    account_id      = data.aws_caller_identity.current.account_id
    environment     = var.environment
    mgmt_account_id = data.aws_ssm_parameter.mgmt_account_number.value
  }
}

resource "aws_kms_key" "encryption" {
  description         = "KMS key for encryption within ${var.environment} environment"
  enable_key_rotation = true
  policy              = data.template_file.key_policy.rendered
  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-${var.function}-${var.environment}"
    )
  )
}

resource "aws_kms_alias" "encryption" {
  name          = "alias/${var.project}-${var.function}-${var.environment}"
  target_key_id = aws_kms_key.encryption.key_id
}
