variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "environment_full_name" {
  description = "full environment name, e.g. staging"
}

variable "domain" {
  description = "domain, e.g. example.com"
  default     = "nationalarchives.gov.uk"
}

variable "from_address" {
  description = "from address prefix, e.g. do-not-reply"
  default     = "do-not-reply"
}
