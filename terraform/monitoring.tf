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
# Prometheus + Grafana (Autopilot-safe)
##################################
resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace_v1.monitoring]

  name       = "prometheus"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  create_namespace = false

  # 🔥 Stability controls
  timeout         = 900
  wait            = true
  atomic          = true
  cleanup_on_fail = true
  force_update    = true
  replace         = true

  values = [
    <<EOF
##################################
# Disable Autopilot-blocked components
##################################
nodeExporter:
  enabled: false

prometheus-node-exporter:
  enabled: false

kubelet:
  enabled: false

kubeProxy:
  enabled: false

alertmanager:
  enabled: false

##################################
# Prometheus (lightweight + probes)
##################################
prometheus:
  prometheusSpec:
    resources:
      requests:
        cpu: "100m"
        memory: "256Mi"
      limits:
        cpu: "300m"
        memory: "512Mi"

    nodeSelector: {}
    affinity: {}
    tolerations: []

    containers:
      - name: prometheus
        readinessProbe:
          httpGet:
            path: /-/ready
            port: 9090
          initialDelaySeconds: 90
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 10

        startupProbe:
          httpGet:
            path: /-/ready
            port: 9090
          failureThreshold: 30
          periodSeconds: 10

##################################
# Grafana (lightweight + probes)
##################################
grafana:
  enabled: true

  resources:
    requests:
      cpu: "50m"
      memory: "128Mi"
    limits:
      cpu: "100m"
      memory: "256Mi"

  readinessProbe:
    httpGet:
      path: /api/health
      port: 3000
    initialDelaySeconds: 60
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 10

  startupProbe:
    httpGet:
      path: /api/health
      port: 3000
    failureThreshold: 30
    periodSeconds: 10

##################################
# kube-state-metrics (tuned)
##################################
kubeStateMetrics:
  resources:
    requests:
      cpu: "50m"
      memory: "128Mi"
    limits:
      cpu: "100m"
      memory: "256Mi"

  readinessProbe:
    httpGet:
      path: /readyz
      port: 8081
    initialDelaySeconds: 60
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 10

##################################
# General rules
##################################
defaultRules:
  create: true

EOF
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
    resources  = ["pods", "services", "endpoints"]
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
# Alloy Deployment (Autopilot-safe)
##################################
resource "kubernetes_deployment_v1" "alloy" {
  depends_on = [
    helm_release.prometheus,
    kubernetes_config_map_v1.alloy_config
  ]

  metadata {
    name      = "grafana-alloy"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    replicas = 1

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

        container {
          name  = "alloy"
          image = "grafana/alloy:v1.2.0"

          args = ["run", "/etc/alloy/config.alloy"]

          resources {
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "256Mi"
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
