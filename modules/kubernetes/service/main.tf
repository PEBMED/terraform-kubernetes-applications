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
      for_each = toset(var.ports)
      content {
        port = each.value
        target_port = each.value
        protocol = var.protocol
        name = "port-${each.value}"
        node_port = var.node_port != "" && each.key == 0 ? var.node_port : 0
      }
    }

    type       = local.service_type
    cluster_ip = var.ip_address
  }
}
