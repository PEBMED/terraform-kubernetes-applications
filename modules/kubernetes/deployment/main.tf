resource "kubernetes_deployment" "deployment" {

  metadata {
    name = var.name
    labels = {
      app = var.name
    }
  }

  spec {
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "50%"
        max_unavailable = 0
      }
    }

    replicas               = var.replicas
    revision_history_limit = 3
    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "app"
                  operator = "In"
                  values   = [var.name]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }
        container {
          image             = "${var.registry}/${var.image}"
          image_pull_policy = var.image_pull_policy
          name              = var.name


          dynamic "volume_mount" {
            for_each = var.mount_path != "" ? [var.mount_path] : []
            content {
              mount_path = var.mount_path
              name       = "source-code"
              read_only  = "false"
            }
          }

          dynamic "env" {
            for_each = var.env
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            requests = {
              cpu    = var.requests["cpu"]
              memory = var.requests["memory"]
            }
            limits = {
              cpu    = var.environment != "develop" ? var.requests["cpu"] : "1000mi"
              memory = var.environment != "develop" ? var.requests["memory"] : "1G"
            }
          }

          liveness_probe {
            tcp_socket {
              port = var.ports[0]
            }
            # http_get {
            #   path    = "/"
            #   port    = var.ports[0]
            #   scheme  = var.protocol
            # }
            initial_delay_seconds = var.probe["initial_delay_seconds"]
            period_seconds        = var.probe["period_seconds"]
            success_threshold     = var.probe["success_threshold"]
            timeout_seconds       = var.probe["timeout_seconds"]
          }
          readiness_probe {
            tcp_socket {
              port = var.ports[0]
            }
            # http_get {
            #   path    = "/"
            #   port    = var.ports[0]
            #   scheme  = var.protocol
            # }
            initial_delay_seconds = var.probe["initial_delay_seconds"]
            period_seconds        = var.probe["period_seconds"]
            success_threshold     = var.probe["success_threshold"]
            timeout_seconds       = var.probe["timeout_seconds"]
          }
        }
        dns_policy = var.dns_policy
        dns_config {
          option {
            name = "ndots"
            value = 1
          }
        }
        restart_policy                   = "Always"
        termination_grace_period_seconds = 30
        dynamic "volume" {
          for_each = var.root_path != "" ? [var.root_path] : []
          content {
            host_path { path = var.root_path }
            name = "source-code"
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec[0].replicas]
  }
}
