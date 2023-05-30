locals {
  max_unavailable = "${
    var.environment != "production"
      ? 0
      : 0
  }"
}

data "kubernetes_secret_v1" "secret" {
  # count = var.environment != "production" ? 0 : 1
  metadata {
    name = var.name
  }
}

resource "kubernetes_deployment" "deployment_develop_homolog" {
  count = var.environment != "production" ? 1 : 0
  metadata {
    name = var.name
  }

  spec {
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "50%"
        max_unavailable = local.max_unavailable
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
          }

          liveness_probe {
            tcp_socket {
              port = var.ports[0]
            }
            initial_delay_seconds = var.probe["initial_delay_seconds"]
            period_seconds        = var.probe["period_seconds"]
            success_threshold     = var.probe["success_threshold"]
            timeout_seconds       = var.probe["timeout_seconds"]
          }
          readiness_probe {
            tcp_socket {
              port = var.ports[0]
            }
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
  timeouts {
    create = "4m"
    update = "4m"
  }
}


resource "kubernetes_deployment" "deployment_production" {
  count = var.environment != "production" ? 0 : 1
  metadata {
    name = var.uuid
    labels = {
      app = var.uuid
      alias = var.name
      namespace = "default"
      tier = var.tier
    }
  }

  spec {
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "50%"
        max_unavailable = local.max_unavailable
      }
    }

    replicas               = var.replicas
    revision_history_limit = 3
    selector {
      match_labels = {
        app = var.uuid
      }
    }

    template {
      metadata {
        labels = {
          app = var.uuid
          alias = var.name
          namespace = "default"
          tier = var.tier
        }
        annotations = {
          "prometheus.io/port" = "8080"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        node_selector = {
          workload = "general"
        }
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "app"
                  operator = "In"
                  values   = [var.uuid]
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

          env_from {
            secret_ref {
              name = "shared-secrets"
            }
          }
          env_from {
            secret_ref {
              name = var.name
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
              cpu    = var.limits["cpu"]
              memory = var.limits["memory"]
            }
            limits = {
              cpu    = var.limits["cpu"]
              memory = var.limits["memory"]
            }
          }

          liveness_probe {
            http_get {
              path    = var.healthcheck_path
              port    = var.healthcheck_port == "" ? var.ports[0] : var.healthcheck_port
              scheme  = var.protocol
            }
            initial_delay_seconds = var.probe["initial_delay_seconds"]
            period_seconds        = var.probe["period_seconds"]
            success_threshold     = var.probe["success_threshold"]
            timeout_seconds       = var.probe["timeout_seconds"]
          }
          readiness_probe {
            http_get {
              path    = var.healthcheck_path
              port    = var.healthcheck_port == "" ? var.ports[0] : var.healthcheck_port
              scheme  = var.protocol
            }
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
      }
    }
  }
  wait_for_rollout = true
  lifecycle {
    ignore_changes = [spec[0].replicas]
  }
}
