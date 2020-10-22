resource "aws_securityhub_account" "security_hub" {}

resource "aws_securityhub_standards_subscription" "security_ruleset" {
  depends_on    = [aws_securityhub_account.security_hub]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}