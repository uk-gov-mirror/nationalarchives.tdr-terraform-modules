output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.cloudfront_distribution.arn
}
