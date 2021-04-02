resource "kubernetes_horizontal_pod_autoscaler" "hpa" {
  metadata {
    name = var.name
  }

  spec {
    min_replicas                      = var.replicas["min"]
    max_replicas                      = var.replicas["max"]
    target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1beta1"
      kind        = "Deployment"
      name        = var.name
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type  = "Utilization"
          average_utilization = 80
        }
      }
    }
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type  = "Utilization"
          average_utilization = 80
        }
      }
    }
  }
}