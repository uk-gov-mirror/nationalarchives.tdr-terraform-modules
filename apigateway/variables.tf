variable "template_params" {
  default = {}
  type    = map(string)
}
variable "template" {}
variable "name" {}
variable "environment" {}
variable "common_tags" {}
variable "region" {
  default = "eu-west-2"
}
