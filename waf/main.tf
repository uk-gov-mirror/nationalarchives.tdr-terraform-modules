resource "aws_wafregional_ipset" "trusted" {
  name = "${var.project}-${var.function}-${var.environment}-whitelist"

  dynamic "ip_set_descriptor" {
    iterator = ip
    for_each = var.trusted_ips
    content {
      type  = "IPV4"
      value = ip.value
    }
  }
}

resource "aws_wafregional_byte_match_set" "restricted_uri" {
  name = "${var.project}-${var.function}-${var.environment}-restricted-uri"
  byte_match_tuples {
    text_transformation   = "NONE"
    target_string         = var.restricted_uri
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_wafregional_rule" "restricted_access" {
  name        = "${var.project}-${var.function}-${var.environment}-restricted-uri"
  metric_name = "RestrictedUri"

  predicate {
    data_id = aws_wafregional_ipset.trusted.id
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_byte_match_set.restricted_uri.id
    negated = false
    type    = "ByteMatch"
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-${var.function}-${var.environment}-restricted-uri",
    )
  )

}

resource "aws_wafregional_web_acl" "restricted_uri" {
  name        = "${var.project}-${var.function}-${var.environment}-restricted-uri"
  metric_name = "RestrictedUri"

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = aws_wafregional_rule.restricted_access.id
    type     = "REGULAR"
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-${var.function}-${var.environment}-restricted-uri",
    )
  )
}
/*
resource "aws_wafregional_web_acl_association" "alb_web_acl" {
  resource_arn = var.alb_target_group_arn
  web_acl_id   = aws_wafregional_web_acl.restricted_uri.id
}
*/