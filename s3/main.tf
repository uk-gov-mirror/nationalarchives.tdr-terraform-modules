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

  block_public_acls   = var.block_public_acls
  block_public_policy = var.block_public_policy
}