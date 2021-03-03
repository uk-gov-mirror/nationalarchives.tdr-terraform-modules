variable "project" {}
variable "function" {}
variable "common_tags" {}
variable "access_point_path" {
  default = "/"
}
variable "policy" {
  default = "restrict_access_points"
}

variable "mount_target_security_groups" {
  description = "Security groups which are allowed to access the mount target"
  type        = list(string)
}

variable "netnum_offset" {
  description = "The offset to be added to the count variable for the netnum argument of cidrsubnet"
  type        = number
  default     = 4
}

variable "nat_gateway_ids" {}
variable "vpc_id" {}
variable "vpc_cidr_block" {}