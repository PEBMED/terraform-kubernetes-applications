resource "kubernetes_horizontal_pod_autoscaler" "hpa" {
  metadata {
    name = var.name
  }

  spec {
    max_replicas                      = 20
    min_replicas                      = 2
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
          value = 80
        }
      }
    }

  }
}
