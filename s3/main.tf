resource "aws_s3_bucket" "log_bucket" {
  count  = var.access_logs == true ? 1 : 0
  acl    = "log-delivery-write"
  bucket = "${local.bucket_name}-logs"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.kms_key_id == "" ? "AES256" : "aws:kms"
        kms_master_key_id = var.kms_key_id == "" ? null : var.kms_key_id
        }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${local.bucket_name}-logs",
    )
  )
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  count  = var.access_logs == true ? 1 : 0
  bucket = aws_s3_bucket.log_bucket.*.id[0]

  block_public_acls   = true
  block_public_policy = true
}

data "template_file" "log_bucket_policy" {
  count    = var.access_logs == true ? 1 : 0
  template = file("./tdr-terraform-modules/s3/templates/secure_transport.json.tpl")
  vars = {
    bucket_name = aws_s3_bucket.log_bucket.*.id[0]
  }
}

resource "aws_s3_bucket_policy" "log_bucket" {
  count  = var.access_logs == true ? 1 : 0
  bucket = aws_s3_bucket.log_bucket.*.id[0]
  policy = data.template_file.log_bucket_policy.*.rendered[0]
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
  acl    = var.acl
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = var.versioning
  }

  dynamic "logging" {
    for_each = var.access_logs == true ? ["include_block"] : []
    content {
      target_bucket = aws_s3_bucket.log_bucket.*.id[0]
      target_prefix = local.bucket_name
    }
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", local.bucket_name,
    )
  )
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

data "template_file" "bucket_policy" {
  template = file("./tdr-terraform-modules/s3/templates/${var.bucket_policy}.json.tpl")
  vars = {
    bucket_name = aws_s3_bucket.bucket.id
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.template_file.bucket_policy.rendered
}