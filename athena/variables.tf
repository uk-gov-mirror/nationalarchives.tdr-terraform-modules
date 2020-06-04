variable "apply_resource" {
  description = "use to conditionally apply resource from the calling module"
  default     = true
}

variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the bucket name"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "bucket" {
  description = "S3 bucket used by Athena to store saved queries and results"
  default     = ""
}

variable "queries" {
  description = "comma separated list of queries"
  default     = []
}
