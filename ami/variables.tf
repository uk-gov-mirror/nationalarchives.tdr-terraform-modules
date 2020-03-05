variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "environment" {
  description = "environment, e.g. prod"
}

variable "region" {
  description = "AWS region"
}

variable "kms_key_id" {
  description = "KMS encryption key ID"
}

variable "source_ami" {
  description = "source AMI before encryption using KMS key"
}
