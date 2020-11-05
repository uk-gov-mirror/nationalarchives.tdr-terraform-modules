variable "common_tags" {}
variable "name" {}
variable "environment" {}
variable "definition_variables" {
  default = {}
  type    = map(string)
}
variable "definition" {}
variable "project" {}
variable "policy" {}
variable "policy_variables" {
  default = {}
  type    = map(string)
}