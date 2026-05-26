terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.useast1]
    }
  }
}

locals {
  waf_name = format("%s-%s-%s-cloudfront-waf", var.project, var.function, var.environment)
}

resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = format("aws-waf-logs-%s", local.waf_name)
  tags              = var.common_tags
  retention_in_days = var.log_retention_period_days
  provider          = aws.useast1
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront_waf.arn
  provider                = aws.useast1
}

resource "aws_wafv2_ip_set" "allowlist_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-allowlist"
  addresses          = var.allowlist_ips
  ip_address_version = "IPV4"
  scope              = "CLOUDFRONT"
  description        = "Allowed IPs"
  provider           = aws.useast1
}

resource "aws_wafv2_ip_set" "blocklist_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-blocklist"
  addresses          = var.blocklist_ips
  ip_address_version = "IPV4"
  scope              = "CLOUDFRONT"
  description        = "Blocked IPs"
  provider           = aws.useast1
}

resource "aws_wafv2_web_acl" "cloudfront_waf" {
  provider = aws.useast1
  name     = local.waf_name
  scope    = "CLOUDFRONT"
  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags

  rule {
    name     = "AWS-AWSManagedRulesAntiDDoSRuleSet"
    priority = 5
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAntiDDoSRuleSet"
        vendor_name = "AWS"

        managed_rule_group_configs {
          aws_managed_rules_anti_ddos_rule_set {
            sensitivity_to_block = "LOW"

            client_side_action_config {
              challenge {
                sensitivity     = "HIGH"
                usage_of_action = "DISABLED"

                exempt_uri_regular_expression {
                  regex_string = "\\/api\\/|\\.(acc|avi|css|gif|ico|jpe?g|js|json|mp[34]|ogg|otf|pdf|png|tiff?|ttf|webm|webp|woff2?|xml)$"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAntiDDoSRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block_in_blocklist"
    priority = 10
    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocklist_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-in-blocklist"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate_control"
    priority = 15
    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = "IP"
        evaluation_window_sec = var.rate_limit_evaluation_window_secs
        limit                 = var.rate_limit
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rate-control"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 20
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 25
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "NoUserAgent_HEADER"
          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "allow_GT8K_body_uploads"
    priority = 26

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          label_match_statement {
            key   = "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body"
            scope = "LABEL"
          }
        }
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = "/cookies"

            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-allow-GT8K-body-uploads"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 30
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "allow_in_allowlist"
    priority = 35
    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowlist_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-allow-in-allowlist"
      sampled_requests_enabled   = true
    }
  }
}
