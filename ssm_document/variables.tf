variable "content_template" {}

variable "template_parameters" {
  type    = map(string)
  default = {}
}

variable "document_type" {
  default = "Command"
}

variable "document_name" {}
