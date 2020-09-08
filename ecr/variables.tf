variable "tag_mutability" {
  default = "MUTABLE"
}
variable "name" {}

variable "policy_name" {
  default = ""
}

variable "policy_variables" {
  type    = map
  default = {}
}