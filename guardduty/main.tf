# Create IP Set for GuardDuty in S3 bucket
resource "aws_s3_bucket_object" "trusted_ip_list" {
  count   = local.region == var.region ? 1 : 0
  acl     = "private"
  content = local.ip_set
  bucket  = var.bucket_id
  key     = var.bucket_object_key
}

resource "aws_guardduty_detector" "master" {
  enable = true
}

resource "aws_guardduty_ipset" "trusted_ip_list" {
  activate    = true
  detector_id = aws_guardduty_detector.master.id
  format      = "TXT"
  location    = "https://s3.amazonaws.com/${var.bucket_id}/${var.bucket_object_key}"
  name        = "trusted-ip-list-${data.aws_region.current.name}"
}