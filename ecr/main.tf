resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.name
  image_tag_mutability = var.tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.common_tags
}

resource "aws_ecr_repository_policy" "ecr_repository_policy" {
  count      = var.policy_name == "" ? 0 : 1
  policy     = templatefile("./tdr-terraform-modules/ecr/templates/${var.policy_name}.json.tpl", var.policy_variables)
  repository = aws_ecr_repository.ecr_repository.name
}