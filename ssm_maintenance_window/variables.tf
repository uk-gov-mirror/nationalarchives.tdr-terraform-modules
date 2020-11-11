variable "name" {}
variable "schedule" {}
variable "duration" {
  default = 1
}
variable "cutoff" {
  default = 0
}
variable "ec2_instance_id" {
  description = "The ID of the EC2 target instance to run the command against"
}
variable "command" {
  description = "The command to execute in the task executed by the maintenance window"
}
variable "common_tags" {
  description = "tags used across the project"
  type        = map(string)
  default     = {}
}
