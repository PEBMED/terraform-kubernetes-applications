variable "environment" {}
variable "env" {}
variable "name" {}
variable "registry" {}
variable "image" {}
variable "replicas" { default = "1" }
variable "mount_path" {}
variable "root_path" {}
variable "healthcheck_path" { default = "/healthcheck" }
variable "ports" {}
variable "protocol" { default = "HTTP" }
variable "dns_policy" {}
variable "image_pull_policy" {}

variable "liveness_probe" {
  type = map(string)
  default = {
   initial_delay_seconds = "15"
   period_seconds = "30"
   success_threshold = "1"
   timeout_seconds = "3"
  }
}

variable "requests" {
  type = map(string)
  default = {
    cpu = "0.1"
    memory = "64m"
  }
}
