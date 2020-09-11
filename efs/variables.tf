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
  type        = list(list(string))
}