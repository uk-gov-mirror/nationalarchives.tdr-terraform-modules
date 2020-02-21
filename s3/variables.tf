variable "common_tags" {}

variable "function" {}

variable "project" {}

variable "environment_suffix" {
  description = "includes environment suffix in bucket name"
  default     = true
}

variable "acl" {
  default = "private"
}

variable "versioning" {
  default = true
}

variable "block_public_acls" {
  default = true
}

variable "block_public_policy" {
  default = true
}
