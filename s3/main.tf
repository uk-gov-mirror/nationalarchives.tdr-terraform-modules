resource "aws_s3_bucket" "log_bucket" {
  count         = var.access_logs == true && var.apply_resource == true ? 1 : 0
  bucket        = "${local.bucket_name}-logs"
  force_destroy = var.force_destroy

  tags = merge(
    local.s3_log_bucket_tags,
    tomap(
      { "Name" = "${local.bucket_name}-logs" }
    )
  )
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  count = var.access_logs == true && var.apply_resource == true ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_logs_ownership" {
  count  = var.access_logs == true && var.apply_resource == true ? 1 : 0
  bucket = aws_s3_bucket.log_bucket[count.index].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  count = var.access_logs == true && var.apply_resource == true ? 1 : 0

  bucket     = aws_s3_bucket.log_bucket[count.index].id
  acl        = "log-delivery-write"
  depends_on = [aws_s3_bucket_ownership_controls.s3_logs_ownership]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = local.s3_bucket_id

  rule {
    bucket_key_enabled = var.bucket_key_enabled

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id == "" ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_id == "" ? null : var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  count                   = var.access_logs == true && var.apply_resource == true ? 1 : 0
  bucket                  = aws_s3_bucket.log_bucket.*.id[0]
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# The account_id and aws_logs_delivery_account_id are used to create the bucket policy
# that matched the previous canonical user grants. The only time the canonical user grants
# were used both the account and aws log delivery account canonical user ids were used.
resource "aws_s3_bucket_policy" "log_bucket" {
  count  = var.access_logs == true && var.apply_resource == true ? 1 : 0
  bucket = aws_s3_bucket.log_bucket.*.id[0]
  policy = templatefile("./tdr-terraform-modules/s3/templates/secure_transport.json.tpl",
    {
      bucket_name                  = aws_s3_bucket.log_bucket.*.id[0],
      account_id                   = data.aws_caller_identity.current.account_id,
      aws_logs_delivery_account_id = var.aws_logs_delivery_account_id
      aws_backup_local_role        = var.aws_backup_local_role_arn
  })
  depends_on = [aws_s3_bucket_public_access_block.log_bucket]
}

# This module is to be deprecated
resource "aws_s3_bucket" "bucket" {
  count         = var.apply_resource == true ? 1 : 0
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  tags = merge(
    local.s3_bucket_tags,
    tomap(
      { "Name" = local.bucket_name }
    )
  )
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  count = var.apply_resource == true && length(var.aws_logs_delivery_account_id) == 0 ? 1 : 0

  bucket = aws_s3_bucket.bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count = var.access_logs == true && var.apply_resource == true ? 1 : 0

  bucket        = aws_s3_bucket.bucket[0].id
  target_bucket = aws_s3_bucket.log_bucket[0].id
  target_prefix = "${local.bucket_name}/${data.aws_caller_identity.current.account_id}/"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count = var.apply_resource == true && (length(var.lifecycle_rules) > 0 || var.abort_incomplete_uploads == true) ? 1 : 0

  bucket = aws_s3_bucket.bucket[0].id

  dynamic "rule" {
    for_each = var.abort_incomplete_uploads == true ? ["this"] : []
    content {
      id     = "abort-incomplete-uploads"
      status = "Enabled"
      abort_incomplete_multipart_upload {
        days_after_initiation = 7
      }
      expiration {
        days                         = 0
        expired_object_delete_marker = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.lifecycle_rules
    iterator = rule
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [rule.value.expiration]
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [rule.value.noncurrent_version_expiration]
        content {
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions", null)
        }
      }

      dynamic "filter" {
        for_each = length(keys(lookup(rule.value, "filter", {}))) == 0 ? [] : [rule.value.filter]
        content {
          prefix                   = lookup(filter.value, "prefix", null)
          object_size_greater_than = lookup(filter.value, "object_size_greater_than", null)
          object_size_less_than    = lookup(filter.value, "object_size_less_than", null)
          dynamic "tag" {
            for_each = length(keys(lookup(filter.value, "tag", {}))) == 0 ? [] : [filter.value.tag]
            content {
              key   = lookup(tag.value, "key")
              value = lookup(tag.value, "value")
            }
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors" {
  count = var.apply_resource == true && length(var.cors_urls) > 0 ? 1 : 0

  bucket = aws_s3_bucket.bucket[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = var.cors_urls
    expose_headers  = ["ETag", "x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  count  = var.apply_resource == true ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]
  policy = local.environment == "mgmt" && contains(["log-data", "lambda_update"], var.bucket_policy) ? templatefile("./tdr-terraform-modules/s3/templates/${var.bucket_policy}.json.tpl",
    {
      bucket_name           = aws_s3_bucket.bucket.*.id[0],
      account_id            = data.aws_caller_identity.current.account_id,
      external_account_1    = data.aws_ssm_parameter.intg_account_number.*.value[0],
      external_account_2    = data.aws_ssm_parameter.staging_account_number.*.value[0],
      external_account_3    = data.aws_ssm_parameter.prod_account_number.*.value[0],
      external_account_4    = data.aws_ssm_parameter.dev_account_number.*.value[0],
      aws_backup_local_role = var.aws_backup_local_role_arn
    }) : templatefile("./tdr-terraform-modules/s3/templates/${var.bucket_policy}.json.tpl",
    {
      bucket_name                  = aws_s3_bucket.bucket.*.id[0],
      aws_elb_account              = data.aws_ssm_parameter.aws_elb_account_number.value,
      account_id                   = data.aws_caller_identity.current.account_id,
      aws_logs_delivery_account_id = var.aws_logs_delivery_account_id,
      environment                  = local.environment, title_environment = title(local.environment),
      read_access_roles            = var.read_access_role_arns,
      cloudfront_distribution_arns = jsonencode(var.cloudfront_distribution_arns)
      aws_backup_local_role        = var.aws_backup_local_role_arn
  })
  depends_on = [aws_s3_bucket_public_access_block.bucket]
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  count                   = var.apply_resource == true ? 1 : 0
  bucket                  = aws_s3_bucket.bucket.*.id[0]
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.apply_resource == true && var.sns_notification && var.sns_topic_arn != "" ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]

  topic {
    topic_arn = var.sns_topic_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_notification" "bucket_lambda_invocation" {
  count  = var.apply_resource == true && var.lambda_notification ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]
  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = var.lambda_arn
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_owner_enforced" {
  count  = var.bucket_owner_object_ownership == true ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_metric" "bucket_request_metrics_all" {
  count  = var.enable_request_metrics_all == true ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]
  name   = "EntireBucket"
}

resource "aws_s3_bucket_metric" "bucket_request_metrics_filter" {
  for_each = var.request_metrics_filters
  bucket   = aws_s3_bucket.bucket.*.id[0]
  name     = each.key

  filter {
    access_point = each.value.access_point
    prefix       = each.value.prefix
    tags         = each.value.tags
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  count  = var.access_logs == true && var.apply_resource == true && length(var.log_bucket_lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.log_bucket[0].id

  dynamic "rule" {
    for_each = var.log_bucket_lifecycle_rules
    iterator = rule
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "expiration" {

        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [rule.value.expiration]
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)

        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [rule.value.noncurrent_version_expiration]
        content {
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions", null)
        }
      }
    }
  }
}
