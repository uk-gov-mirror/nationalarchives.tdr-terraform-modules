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

variable "email_address" {
  description = "address prefix, e.g. secops"
  default     = "tdr-secops"
}

variable "hosted_zone_id" {
  description = "Hosted zone ID"
}