variable "template_params" {
  default = {}
  type    = map(string)
}
variable "api_template" {
  description = "The name of a json template file with the swagger json for the api definition"
}
variable "api_name" {}
variable "environment" {}
variable "common_tags" {}
variable "region" {
  default = "eu-west-2"
}
