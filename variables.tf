variable "k8s_api_address" {}
variable "k8s_config_path" {}
variable "application_name" {}
variable "application_ports" { type = list(number) }
variable "registry" {}
variable "image" { default = "" }
variable "environment" { default = "develop" }
variable "mount_path" { default = "/app" }
variable "root_path" { default = "/src" }
variable "dns_policy" { default = "ClusterFirst" }
variable "service_protocol" { default = "TCP" }
variable "ip" { default = "" }
variable "debug_port" { default = null }
variable "application_env_var" { default = {} }
variable "image_pull_policy" { default = "Always" }
variable "live_coding" { default = "True" }
variable "visibility" { default = "private" }
variable "replicas" {
    type = map(number)
    default = {
        min = 2
        max = 20
    }
}
variable "probe" {
  type = map(string)
  default = {
   initial_delay_seconds = "15"
   period_seconds = "15"
   success_threshold = "1"
   timeout_seconds = "3"
  }
}
variable "aws_cert_arn" { default = "" }
variable "root_domain" { default = "prd.pebmed.com.br" }
variable "limits" {
  type = map(string)
  default = {
    cpu = "250m"
    memory = "256Mi"
  }
}