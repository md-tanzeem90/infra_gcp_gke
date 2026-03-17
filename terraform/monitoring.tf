##################################
# Namespace
##################################
resource "kubernetes_namespace_v1" "monitoring" {
  depends_on = [module.gke]

  metadata {
    name = "monitoring"
  }
}

##################################
# Prometheus + Grafana
##################################
resource "helm_release" "prometheus" {
  depends_on = [module.gke]

  name       = "prometheus"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    file("${path.module}/helm-values/prometheus.yaml")
  ]
}

##################################
# RBAC for Alloy
##################################
resource "kubernetes_service_account_v1" "alloy" {
  metadata {
    name      = "grafana-alloy"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "alloy" {
  metadata {
    name = "grafana-alloy"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "nodes", "services", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "alloy" {
  metadata {
    name = "grafana-alloy"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.alloy.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.alloy.metadata[0].name
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }
}

##################################
# Alloy Config
##################################
resource "kubernetes_config_map_v1" "alloy_config" {
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
    url = "http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/write"
  }
}

otelcol.receiver.otlp "default" {
  grpc {}
  http {}

  output {
    metrics = [prometheus.remote_write.prom.receiver]
  }
}
EOF
  }
}

##################################
# Alloy DaemonSet
##################################
resource "kubernetes_daemon_set_v1" "alloy" {
  depends_on = [
    helm_release.prometheus,
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
        service_account_name = kubernetes_service_account_v1.alloy.metadata[0].name

        toleration {
          operator = "Exists"
        }

        container {
          name  = "alloy"
          image = "grafana/alloy:v1.2.0"

          args = ["run", "/etc/alloy/config.alloy"]

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
