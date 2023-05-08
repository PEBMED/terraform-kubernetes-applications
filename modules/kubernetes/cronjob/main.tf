resource "kubernetes_cron_job_v1" "cronjob" {
  metadata {
    name = var.uuid
    labels = {
      app = var.uuid
      alias = var.name
      namespace = "default"
    }
  }
  spec {
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 2
    schedule                      = var.schedule
    timezone                      = "Etc/UTC"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 5
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name    = var.name
              image   = "${var.registry}/${var.image}"
              image_pull_policy = var.image_pull_policy

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
            }
            dns_policy = var.dns_policy
            dns_config {
                option {
                    name = "ndots"
                    value = 1
                }
            }
          }
        }
      }
    }
  }
}