resource "aws_route53_zone" "hosted_zone" {
  name = var.environment_full_name == "production" ? "${var.project}.${var.domain}" : "${var.project}-${var.environment_full_name}.${var.domain}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-${var.environment_full_name}",
    )
  )
}
# uncomment the block below if importing an existing hosted zone to the Terraform state file
/*
resource "aws_route53_record" "hosted_zone_ns" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = var.environment_full_name == "production" ? "${var.project}.${var.domain}" : "${var.project}-${var.environment_full_name}.${var.domain}"
  type    = "NS"
  ttl     = var.ns_ttl

  records = [
    "${aws_route53_zone.hosted_zone.name_servers.0}.",
    "${aws_route53_zone.hosted_zone.name_servers.1}.",
    "${aws_route53_zone.hosted_zone.name_servers.2}.",
    "${aws_route53_zone.hosted_zone.name_servers.3}.",
  ]
}
*/