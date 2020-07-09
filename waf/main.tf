resource "aws_wafregional_ipset" "trusted" {
  count = var.trusted_ips == "" ? 0 : 1
  name  = "${var.project}-${var.function}-${var.environment}-whitelist"

  dynamic "ip_set_descriptor" {
    iterator = ip
    for_each = var.trusted_ips
    content {
      type  = "IPV4"
      value = ip.value
    }
  }
  lifecycle {
    ignore_changes = [ip_set_descriptor]
  }
}

resource "aws_wafregional_byte_match_set" "restricted_uri" {
  count = var.restricted_uri == "" ? 0 : 1
  name  = "${var.project}-${var.function}-${var.environment}-restricted-uri"

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
  count       = var.restricted_uri == "" ? 0 : 1
  name        = "${var.project}-${var.function}-${var.environment}-restricted-uri"
  metric_name = "RestrictedUri"

  predicate {
    data_id = aws_wafregional_ipset.trusted.*.id[0]
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_byte_match_set.restricted_uri.*.id[0]
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

resource "aws_wafregional_geo_match_set" "geo_match" {
  count = var.geo_match == "" ? 0 : 1
  name  = "geo_match_set"

  dynamic "geo_match_constraint" {
    iterator = country
    for_each = var.geo_match
    content {
      type  = "Country"
      value = country.value
    }
  }
}

resource "aws_wafregional_rule" "geo_match" {
  count       = var.geo_match == "" ? 0 : 1
  name        = "${var.project}-${var.function}-${var.environment}-geo-match"
  metric_name = "GeoMatch"

  predicate {
    data_id = aws_wafregional_geo_match_set.geo_match.*.id[0]
    negated = false
    type    = "GeoMatch"
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-${var.function}-${var.environment}-restricted-uri",
    )
  )
}

resource "aws_wafregional_web_acl" "alb" {
  name        = "${var.project}-${var.function}-${var.environment}-alb"
  metric_name = "ALBWebAcl"

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 10
    rule_id  = aws_wafregional_rule.restricted_access.*.id[0]
    type     = "REGULAR"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 20
    rule_id  = aws_wafregional_rule.geo_match.*.id[0]
    type     = "REGULAR"
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-${var.function}-${var.environment}-alb",
    )
  )
}

resource "aws_wafregional_web_acl_association" "alb_web_acl" {
  count        = length(var.alb_target_groups)
  resource_arn = var.alb_target_groups[count.index]
  web_acl_id   = aws_wafregional_web_acl.alb.id
}
