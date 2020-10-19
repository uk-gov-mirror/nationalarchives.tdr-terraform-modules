variable "name" {}
variable "schedule" {}
variable "duration" {
  default = 1
}
variable "cutoff" {
  default = 0
}
variable "instance_name" {
  description = "The name of the target instance to run the command against"
}
variable "command" {
  description = "The command to execute in the task executed by the maintenance window"
}

