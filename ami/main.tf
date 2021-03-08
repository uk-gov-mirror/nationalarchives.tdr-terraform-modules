resource "aws_ami_copy" "encrypted-ami" {
  name              = "${var.project}-${var.function}-${var.environment}-${formatdate("YYYY-MM-DD", timestamp())}"
  description       = "Encrypted ami based on ${var.source_ami} created ${formatdate("D MMM YYYY", timestamp())}"
  source_ami_id     = var.source_ami
  source_ami_region = var.region
  encrypted         = "true"
  kms_key_id        = var.kms_key_id
  tags = merge(
    var.common_tags,
    map("Name", "${var.project}-${var.function}-${var.environment}")
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes for fields containing dates
      name,
      description,
    ]
  }
}