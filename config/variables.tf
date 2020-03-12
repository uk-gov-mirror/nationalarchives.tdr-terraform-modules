variable "common_tags" {
  description = "tags used across the project"
}

variable "all_supported" {
  description = "record configuration changes for every supported regional resource"
  default     = true
}

variable "bucket_id" {}

variable "include_global_resource_types" {
  description = "record configuration changes for global resources"
  default     = false
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the bucket name"
}

variable "environment_full_name" {
  description = "full environment name, e.g. staging"
}

variable "primary_region" {
  default = "eu-west-2"
}

variable "primary_config_recorder_id" {
  default = ""
}

variable "global_config_rule_list" {
  description = "list of global config rules without input parameters to be applied in a single region"
  default     = ["IAM_USER_NO_POLICIES_CHECK", "ROOT_ACCOUNT_MFA_ENABLED"]
}

variable "regional_config_rule_list" {
  description = "list of global config rules without input parameters to be applied in every region"
  default     = ["INCOMING_SSH_DISABLED", "VPC_DEFAULT_SECURITY_GROUP_CLOSED"]
}