variable "common_tags" {}
variable "step_function_name" {}
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
