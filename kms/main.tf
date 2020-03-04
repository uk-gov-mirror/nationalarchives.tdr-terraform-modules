resource "aws_kms_key" "encryption" {
  description         = "KMS key for encryption within ${var.environment} environment"
  enable_key_rotation = true
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