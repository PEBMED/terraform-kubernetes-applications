terraform {
  required_version = ">= 0.12"
}

locals {
  deployment_container_image = "${
    var.image != ""
    ? var.image
    : "${var.application_name}:${var.environment}"
  }"
}

locals {
  root_path = "${
    var.root_path != ""
    ? "${format("/applications/%s", var.application_name)}${var.root_path}"
    : "${format("/applications/%s/src", var.application_name)}"
  }"
}

locals {
  mount_path = "${
    var.mount_path != ""
    ? var.mount_path
    : "/app"
  }"
}

provider "kubernetes" {
  host        = var.k8s_api_address
  config_path = var.k8s_config_path
}

module "deployment" {
  source      = "./modules/kubernetes/deployment"
  environment = var.environment
  env         = var.env
  name        = var.application_name
  ports       = var.application_ports
  registry    = var.registry
  image       = local.deployment_container_image
  mount_path  = local.mount_path
  root_path   = local.root_path
  dns_policy  = var.dns_policy
}

module "service" {
  source     = "./modules/kubernetes/service"
  name       = var.application_name
  ports      = var.application_ports
  ip_address = var.ip
  node_port  = var.debug_port
}

