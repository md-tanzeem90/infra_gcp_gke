##################################
# 1. Monitoring Namespace
##################################
resource "kubernetes_namespace_v1" "monitoring" {
  depends_on = [module.gke]

  metadata {
    name = "monitoring"
  }
}

##################################
# 2. Grafana Alloy ConfigMap
##################################
resource "kubernetes_config_map_v1" "alloy_config" {
  depends_on = [module.gke]

  metadata {
    name      = "grafana-alloy-config"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  data = {
    "config.alloy" = <<EOF
discovery.kubernetes "pods" {
  role = "pod"
}

prometheus.scrape "pods" {
  targets    = discovery.kubernetes.pods.targets
  forward_to = [prometheus.remote_write.prom.receiver]
}

prometheus.remote_write "prom" {
  endpoint {
    url = "http://monitoring-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/write"
  }
}
EOF
  }
}

##################################
# 3. Grafana Alloy DaemonSet
##################################
resource "kubernetes_daemon_set_v1" "grafana_alloy" {
  depends_on = [
    module.gke,
    kubernetes_namespace_v1.monitoring,
    kubernetes_config_map_v1.alloy_config
  ]

  metadata {
    name      = "grafana-alloy"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "grafana-alloy"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana-alloy"
        }
      }

      spec {
        container {
          name  = "alloy"
          image = "grafana/alloy:latest"

          args = [
            "run",
            "/etc/alloy/config.alloy"
          ]

          resources {
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
            limits = {
              cpu    = "300m"
              memory = "400Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/alloy"
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.alloy_config.metadata[0].name
          }
        }
      }
    }
  }
}
