variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "function" {
  description = "forms the second part of the certificate name, eg. jenkins"
}

variable "common_tags" {
  description = "tags used across the project"
}

variable "dns_zone" {
  description = "DNS zone domain, e.g. example.com"
}

variable "domain_name" {
  description = "domain name to include in certificate, e.g. app.example.com"
}