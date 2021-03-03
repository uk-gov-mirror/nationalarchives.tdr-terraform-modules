resource "aws_efs_file_system" "file_system" {
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
  encrypted  = true
  kms_key_id = data.aws_kms_key.efs_kms_key.arn
  tags = merge(
    var.common_tags,
    map(
      "Name", local.efs_volume_name,
    )
  )
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.file_system.id
  posix_user {
    gid = 1001
    uid = 1001
  }
  root_directory {
    path = var.access_point_path
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = 755
    }
  }
}

resource "aws_efs_file_system_policy" "file_system_policy" {
  file_system_id = aws_efs_file_system.file_system.id
  policy         = templatefile("${path.module}/templates/${var.policy}.json.tpl", { file_system_arn = aws_efs_file_system.file_system.arn })
}

resource "aws_security_group" "mount_target_sg" {
  name        = "${var.function}-mount-target-security-group"
  description = "Mount target security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "EFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.mount_target_security_groups
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    map("Name", "mount-target-outbound-only")
  )
}

resource "aws_subnet" "efs_private" {
  count             = 2
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 6, count.index + var.netnum_offset)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = var.vpc_id
  tags = merge(
    var.common_tags,
    map("Name", "tdr-efs-private-subnet-${var.function}-${count.index}-${local.environment}")
  )
}

resource "aws_route_table" "efs_private" {
  count  = 2
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[count.index]
  }

  tags = merge(
    var.common_tags,
    map("Name", "route-table-${count.index}-tdr-${local.environment}")
  )
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.efs_private.*.id[count.index]
  route_table_id = aws_route_table.efs_private.*.id[count.index]
}

resource "aws_efs_mount_target" "mount_target_az_zero" {
  file_system_id  = aws_efs_file_system.file_system.id
  subnet_id       = aws_subnet.efs_private.*.id[0]
  security_groups = [aws_security_group.mount_target_sg.id]
}

resource "aws_efs_mount_target" "mount_target_az_one" {
  file_system_id  = aws_efs_file_system.file_system.id
  subnet_id       = aws_subnet.efs_private.*.id[1]
  security_groups = [aws_security_group.mount_target_sg.id]
}