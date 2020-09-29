resource "aws_instance" "instance" {
  ami                    = var.encrypted_ami_id
  instance_type          = "t2.micro"
  iam_instance_profile   = local.iam_role_count == 1 ? aws_iam_instance_profile.instance_profile[0].name : ""
  subnet_id              = data.aws_subnet.public_subnet.id
  user_data = var.user_data != "" ? templatefile("${path.module}/templates/${var.user_data}.sh.tpl", var.user_data_variables) : ""
  tags = merge(
  var.common_tags,
  map(
  "Name", "${var.name}-ec2-instance-${var.environment}",
  )
  )
}

resource "aws_iam_instance_profile" "instance_profile" {
  count = local.iam_role_count
  name = var.name
  role = aws_iam_role.ec2_role[count.index].name
}

resource "aws_iam_role" "ec2_role" {
  count = local.iam_role_count
  name               = "${title(var.name)}EC2Role${title(var.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ec2_assume_role.json.tpl", {})
  tags = merge(
  var.common_tags,
  map(
  "Name", "${var.name}-ec2-iam-role-${var.environment}",
  )
  )
}

resource "aws_iam_policy" "ec2_policy" {
  name               = "${title(var.name)}EC2Policy${title(var.environment)}"
  count = local.iam_role_count
  policy = templatefile("${path.module}/templates/${var.iam_policy}.json.tpl", var.policy_variables)
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  count = local.iam_role_count
  policy_arn = aws_iam_policy.ec2_policy[count.index].arn
  role = aws_iam_role.ec2_role[count.index].name
}
