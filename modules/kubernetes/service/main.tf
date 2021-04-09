locals {
  service_type_develop = "${
    var.node_port != null
      ? "LoadBalancer"
      : "ClusterIP"
  }"
  service_type_production = "${
    var.visibility == "public" && var.environment == "production"
      ? "LoadBalancer"
      : "ClusterIP"
  }"
  visibility_annotation = "${
    var.visibility != "private"
      ? "false"
      : "true"
  }"
  loadbalancer_protocol = "${
    var.visibility != "private"
      ? "https"
      : "http"
  }"
  loadbalancer_ssl_port = "${
    var.visibility != "private"
      ? "443"
      : "*"
  }"
}

resource "kubernetes_service" "develop" {
  count = var.environment == "develop" ? 1 : 0
  metadata {
    name = var.name
    annotations = {
      "external-dns.alpha.kubernetes.io/aws-weight": "100"
      "external-dns.alpha.kubernetes.io/hostname": "${var.name}.${var.root_domain}"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": var.aws_cert_arn
      "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout": "600"
      "service.beta.kubernetes.io/aws-load-balancer-connection-draining-enabled": "false"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": local.loadbalancer_protocol
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": local.loadbalancer_ssl_port
      "external-dns.alpha.kubernetes.io/set-identifier": var.environment
      "service.beta.kubernetes.io/aws-load-balancer-internal": local.visibility_annotation
    }
  }
  spec {
    selector = {
      app = var.name
    }
    session_affinity = "None"

    dynamic "port" {
      for_each = var.ports
      content {
        port = port.value
        target_port = port.value
        protocol = var.protocol
        name = "port-${port.value}"
        node_port = var.node_port != "" && port.key == 0 ? var.node_port : 0
      }
    }

    type       = local.service_type_develop
    cluster_ip = var.ip_address
  }
}


resource "kubernetes_service" "homolog_and_production" {
  count = var.environment != "develop" ? 1 : 0
  metadata {
    name = var.name
    annotations = {
      "external-dns.alpha.kubernetes.io/aws-weight": "100"
      "external-dns.alpha.kubernetes.io/hostname": "${var.name}.${var.root_domain}"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": var.aws_cert_arn
      "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout": "600"
      "service.beta.kubernetes.io/aws-load-balancer-connection-draining-enabled": "false"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": local.loadbalancer_protocol
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": local.loadbalancer_ssl_port
      "external-dns.alpha.kubernetes.io/set-identifier": var.environment
      "service.beta.kubernetes.io/aws-load-balancer-internal": local.visibility_annotation
    }
  }
  spec {
    selector = {
      app = var.name
    }
    session_affinity = "None"

    dynamic "port" {
      for_each = var.ports
      content {
        port = port.value
        target_port = port.value
        protocol = var.protocol
        name = "port-${port.value}"
      }
    }

    type       = local.service_type_production
    cluster_ip = var.ip_address
  }
}
