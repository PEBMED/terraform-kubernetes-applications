variable "environment" {}
variable "env" {}
variable "name" {}
variable "registry" {}
variable "image" {}
variable "replicas" { default = "1" }
variable "mount_path" {}
variable "root_path" {}
variable "healthcheck_path" {}
variable "healthcheck_port" { default = "" }
variable "ports" {}
variable "protocol" { default = "HTTP" }
variable "dns_policy" {}
variable "image_pull_policy" {}
variable "probe" { type = map(string) }
variable "requests" {
  type = map(string)
  default = {
    cpu = "10m"
    memory = "64Mi"
  }
}
variable "limits" {}
variable "uuid" {}
variable "tier" {}