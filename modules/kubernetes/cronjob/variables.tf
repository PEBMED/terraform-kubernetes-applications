variable "name" {}
variable "registry" {}
variable "image" {}
variable "uuid" {}
variable "image_pull_policy" {}
variable "env" {}
variable "environment" {}
variable "requests" {
  type = map(string)
  default = {
    cpu = "10m"
    memory = "64Mi"
  }
}
variable "limits" {}
variable "dns_policy" {}