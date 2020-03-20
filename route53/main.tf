resource "aws_route53_zone" "hosted_zone" {
  name = var.environment_full_name == "production" ? "${var.project}.${var.domain}" : "${var.project}-${var.environment_full_name}.${var.domain}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.project}-${var.environment_full_name}",
    )
  )
}
# conditional includes the block below for environments with a manually created hosted zone imported to the Terraform state file
resource "aws_route53_record" "hosted_zone_ns" {
  count   = var.manual_creation == true ? 1 : 0
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
