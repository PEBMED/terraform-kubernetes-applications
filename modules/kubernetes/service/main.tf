locals {
  service_type = "${
    var.node_port != ""
      ? "ClusterIP"
      : "LoadBalancer"
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

resource "kubernetes_service" "service" {
  metadata {
    name = var.name
    annotations = {
      "external-dns.alpha.kubernetes.io/aws-weight": "100"
      "external-dns.alpha.kubernetes.io/hostname": "TDB"
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

    type       = local.service_type
    cluster_ip = var.ip_address
  }
}
