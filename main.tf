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
    var.root_path != "" && var.environment == "dev"
    ? "${format("/applications/%s", var.application_name)}${var.root_path}"
    : ""
  }"
}

locals {
  mount_path = "${
    var.mount_path != "" && var.environment == "dev"
    ? var.mount_path
    : ""
  }"
}

locals {
  debug_port = "${
    var.debug_port != "" && var.environment == "dev"
    ? var.debug_port
    : ""
  }"
}

provider "kubernetes" {
  host        = var.k8s_api_address
  config_path = var.k8s_config_path
}

module "deployment" {
  source            = "./modules/kubernetes/deployment"
  environment       = var.environment
  env               = var.application_env_var
  name              = var.application_name
  ports             = var.application_ports
  registry          = var.registry
  image             = local.deployment_container_image
  mount_path        = local.mount_path
  root_path         = local.root_path
  dns_policy        = var.dns_policy
  image_pull_policy = var.image_pull_policy
}

module "service" {
  source     = "./modules/kubernetes/service"
  name       = var.application_name
  ports      = var.application_ports
  ip_address = var.ip
  node_port  = local.debug_port
  protocol   = var.service_protocol
}

