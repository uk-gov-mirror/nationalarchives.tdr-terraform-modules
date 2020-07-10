data "aws_caller_identity" "current" {}
data "aws_vpc" "current" {
  tags = {
    Name = "tdr-vpc-${local.environment}"
  }
}
