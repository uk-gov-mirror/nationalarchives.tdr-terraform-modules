variable "common_tags" {}

variable "tag_mutability" {
  default = "MUTABLE"
}
variable "name" {}

variable "image_source_url" {
  type        = string
  default     = "unknown"
  description = "The URL of the Dockerfile or other source used to build the images in this repository"
}

variable "policy_name" {
  default = ""
}

variable "policy_variables" {
  type    = map
  default = {}
}
