resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "S3CloudFrontOAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_request_policy" "request_policy" {
  name = "s3-multipart-upload"
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
  cookies_config {
    cookie_behavior = "none"
  }
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases    = [var.alias_domain_name]
  enabled    = true
  web_acl_id = var.waf_arn
  logging_config {
    bucket = var.logging_bucket_regional_domain_name
  }
  default_cache_behavior {
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    target_origin_id           = local.s3_origin_id_oac
    viewer_protocol_policy     = "https-only"
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.request_policy.id
    trusted_key_groups         = [aws_cloudfront_key_group.cookie_signing_keys_group.id, aws_cloudfront_key_group.cookie_signing_key_group.id]
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default_response_headers_policy.id
  }

  origin {
    domain_name              = var.s3_regional_domain_name
    origin_id                = local.s3_origin_id_oac
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  origin {
    domain_name = split("/", var.api_gateway_url)[2]
    origin_id   = local.api_gateway_origin_id
    origin_path = "/${var.environment}"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  ordered_cache_behavior {
    path_pattern             = "/cookies"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["HEAD", "GET"]
    target_origin_id         = local.api_gateway_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.cache_policy.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.sign_cookies_api_policy.id

    compress                   = true
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default_response_headers_policy.id
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
    acm_certificate_arn      = var.certificate_arn
  }
}

resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = "tdr-signed-cookies-cache-policy-${var.environment}"
  min_ttl     = 1
  max_ttl     = 1
  default_ttl = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization"]
      }
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    cookies_config {
      cookie_behavior = "all"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "sign_cookies_api_policy" {
  name = "tdr-sign-cookies-api-origin-${var.environment}"
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

# Old
resource "aws_cloudfront_public_key" "cookie_signing_key" {
  comment     = "Public key for signed cookies"
  encoded_key = file("${path.module}/keys/sign_cookies_public_key_${var.environment}.pem")
  name        = "tdr-signed-cookie-public-key-${var.environment}"
}

resource "aws_cloudfront_key_group" "cookie_signing_key_group" {
  comment = "Key group for the signed cookie key"
  items   = [aws_cloudfront_public_key.cookie_signing_key.id]
  name    = "tdr-signed-cookie-group-${var.environment}"
}

# New
resource "aws_cloudfront_public_key" "cookie_signing_keys" {
  for_each    = toset(var.trusted_public_key_file_names)
  comment     = "Public keys for signed cookies"
  encoded_key = file("${path.module}/keys/${each.key}")
}

resource "aws_cloudfront_key_group" "cookie_signing_keys_group" {
  comment = "Key group for the signed cookie keys"
  items   = [for p in aws_cloudfront_public_key.cookie_signing_keys : p.id]
  name    = "tdr-signed-cookies-group-${var.environment}"
}

resource "aws_cloudfront_response_headers_policy" "default_response_headers_policy" {
  name = "tdr-default-response-headers-${var.environment}"
  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      override                   = false
    }
    content_security_policy {
      content_security_policy = "default-src 'self'"
      override                = false
    }
    frame_options {
      frame_option = "DENY"
      override     = false
    }
    content_type_options {
      override = false
    }
    referrer_policy {
      override        = false
      referrer_policy = "origin"
    }
  }
  custom_headers_config {
    items {
      header   = "X-Permitted-Cross-Domain-Policies"
      override = false
      value    = "none"
    }
  }
}
