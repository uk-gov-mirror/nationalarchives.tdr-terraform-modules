resource "aws_s3_bucket" "log_bucket" {
  acl    = "log-delivery-write"
  bucket = "${local.bucket_name}-logs"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
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
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

data "template_file" "log_bucket_policy" {
  template = file("../tdr-terraform-modules/s3/templates/secure_transport.json.tpl")
  vars = {
    bucket_name = aws_s3_bucket.log_bucket.id
  }
}

resource "aws_s3_bucket_policy" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.template_file.log_bucket_policy.rendered
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
  acl    = var.acl

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

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = local.bucket_name
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
  template = file("../tdr-terraform-modules/s3/templates/secure_transport.json.tpl")
  vars = {
    bucket_name = aws_s3_bucket.bucket.id
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.template_file.bucket_policy.rendered
}