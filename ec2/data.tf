data "aws_subnet" "public_subnet" {
  tags = {
    "Name" = "tdr-public-subnet-0-${var.environment}"
  }
}