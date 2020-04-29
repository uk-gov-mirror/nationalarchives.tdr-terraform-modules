output "s3_bucket_id" {
  value = aws_s3_bucket.bucket.*.id[0]
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.bucket.*.arn[0]
}

output "s3_bucket_domain_name" {
  value = aws_s3_bucket.bucket.*.bucket_domain_name[0]
}

output "s3_bucket_regional_domain_name" {
  value = aws_s3_bucket.bucket.*.bucket_regional_domain_name[0]
}
