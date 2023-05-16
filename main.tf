terraform {
  required_version = ">= 0.12"
  # required_providers {
  #   kubernetes = {
  #     source  = "hashicorp/kubernetes"
  #     version = ">= 2.0"
  #   }
  # }
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
    var.environment == "develop" && var.live_coding == "True"
    ? "${format("/applications/%s", var.application_name)}${var.root_path}"
    : ""
  }"
}

locals {
  mount_path = "${
    var.environment == "develop" && var.live_coding == "True"
    ? var.mount_path
    : ""
  }"
}

locals {
  debug_port = "${
    var.environment != "production" && var.debug_port != ""
    ? var.debug_port
    : null
  }"
}

provider "kubernetes" {
  host        = var.k8s_api_address
  config_path = var.k8s_config_path
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
  }
}

resource "random_uuid" "uuid" {
}

module "deployment" {
  source            = "./modules/kubernetes/deployment"
  environment       = var.environment
  env               = var.application_env_var
  name              = var.application_name
  ports             = var.application_ports
  healthcheck_port  = var.healthcheck_port
  healthcheck_path  = var.healthcheck_path
  registry          = var.registry
  image             = local.deployment_container_image
  mount_path        = local.mount_path
  root_path         = local.root_path
  dns_policy        = var.dns_policy
  image_pull_policy = var.image_pull_policy
  probe             = var.probe
  limits            = var.limits
  uuid              = random_uuid.uuid.result
}

module "service" {
  source       = "./modules/kubernetes/service"
  environment  = var.environment
  name         = var.application_name
  ports        = var.application_ports
  ip_address   = var.ip
  node_port    = local.debug_port
  protocol     = var.service_protocol
  visibility   = var.visibility
  aws_cert_arn = var.aws_cert_arn
  root_domain  = var.root_domain
  uuid         = random_uuid.uuid.result
  is_tcp_listener = var.is_tcp_listener
  loadbalancer_idle_timeout = var.loadbalancer_idle_timeout
}

module "hpa" {
  source       = "./modules/kubernetes/hpa"
  name         = var.application_name
  replicas     = var.replicas
  environment  = var.environment
  uuid         = random_uuid.uuid.result
}
