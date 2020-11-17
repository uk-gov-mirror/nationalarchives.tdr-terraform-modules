variable "template_params" {
  default = {}
  type    = map(string)
}
variable "template" {}
variable "name" {}
variable "environment" {}
variable "common_tags" {}
variable "dns_name" {}
variable "certificate_arn" {}
variable "zone_id" {}
