data "aws_route53_zone" "hosted_zone" {
  name = var.environment_full_name == "production" ? "${var.project}.${var.domain}." : "${var.project}-${var.environment_full_name}.${var.domain}."
}
