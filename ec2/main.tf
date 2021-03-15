resource "aws_instance" "instance" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  subnet_id              = var.subnet_id
  user_data              = var.user_data != "" ? templatefile("${path.module}/templates/${var.user_data}.sh.tpl", var.user_data_variables) : ""
  vpc_security_group_ids = [var.security_group_id]
  key_name               = local.key_count == 0 ? "" : "bastion_key"
  ebs_block_device {
    device_name = "/dev/xvda"
    encrypted   = true
    kms_key_id  = var.kms_arn
  }

  lifecycle {
    ignore_changes = [ebs_block_device]
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.name}-ec2-instance-${var.environment}",
    )
  )
}

resource "aws_key_pair" "bastion_key_pair" {
  count      = local.key_count
  public_key = var.public_key
  key_name   = "bastion_key"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = var.name
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name               = "${title(var.name)}EC2Role${title(var.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ec2_assume_role.json.tpl", {})
  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.name}-ec2-iam-role-${var.environment}",
    )
  )
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  for_each = toset(concat(["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"], var.additional_policy_arns))
  policy_arn = each.key
  role       = aws_iam_role.ec2_role.name
}
