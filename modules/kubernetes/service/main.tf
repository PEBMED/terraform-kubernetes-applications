locals {
  service_type = "${
    var.node_port != ""
      ? "LoadBalancer"
      : "ClusterIP"
  }"
}

resource "kubernetes_service" "service" {
  metadata {
    name = var.name
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
