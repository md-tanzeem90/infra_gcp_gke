resource "kubernetes_namespace_v1" "monitoring" {

  depends_on = [
    module.gke
  ]

  metadata {
    name = "monitoring"
  }
} 

resource "kubernetes_config_map_v1" "alloy_config" {

  depends_on = [
    module.gke
  ]

  metadata {
    name      = "grafana-alloy-config"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  data = {
    "config.alloy" = <<EOF
discovery.kubernetes "pods" {
  role = "pod"
}
EOF
  }
}

resource "kubernetes_daemon_set_v1" "grafana_alloy" {

  depends_on = [
    module.gke
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
          }
        }
      }
    }
  }
}
