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
# LimitRange (Autopilot Guardrail)
##################################
resource "kubernetes_limit_range_v1" "monitoring_limits" {
  metadata {
    name      = "monitoring-limits"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    limit {
      type = "Container"

      default_request {
        cpu    = "100m"
        memory = "128Mi"
      }

      default {
        cpu    = "500m"
        memory = "512Mi"
      }
    }
  }
}
##################################
# Prometheus + Grafana 
##################################
resource "helm_release" "prometheus" {
  depends_on = [
    kubernetes_namespace_v1.monitoring,
    kubernetes_limit_range_v1.monitoring_limits
  ]

  name       = "prometheus"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  timeout         = 1200
  wait            = false
  atomic          = false
  cleanup_on_fail = false
  replace         = false

  values = [
    <<EOF

##################################
# Disable infra collectors (Autopilot)
##################################
nodeExporter:
  enabled: false

prometheus-node-exporter:
  enabled: false

kubelet:
  enabled: false

kubeProxy:
  enabled: false

kubeScheduler:
  enabled: false

kubeControllerManager:
  enabled: false

kubeApiServer:
  enabled: false

coreDns:
  enabled: false

kubeDns:
  enabled: false

##################################
# Prometheus Operator (lightweight)
##################################
prometheusOperator:
  resources:
    requests:
      cpu: "100m"
      memory: "128Mi"

  admissionWebhooks:
    enabled: false

##################################
# Prometheus (FIXED + OPTIMIZED)
##################################
prometheus:
  serviceMonitorSelectorNilUsesHelmValues: false
  podMonitorSelectorNilUsesHelmValues: false

  prometheusSpec:
    replicas: 1
    retention: "6h"

    # ❗ Autopilot-friendly sizing (not too small, not too big)
    resources:
      requests:
        cpu: "300m"
        memory: "512Mi"
      limits:
        cpu: "700m"
        memory: "1Gi"

    # ❗ No PVC → avoids scheduling + cost issues
    storageSpec: {}

##################################
# Grafana (secured + stable)
##################################
grafana:
  enabled: true

  adminUser: admin
  adminPassword: admin123

  # ❗ safer than LoadBalancer in Autopilot
  service:
    type: ClusterIP

  ingress:
    enabled: false

  resources:
    requests:
      cpu: "100m"
      memory: "256Mi"
    limits:
      cpu: "300m"
      memory: "512Mi"

  additionalDataSources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090
      isDefault: true

  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard

##################################
# kube-state-metrics
##################################
kubeStateMetrics:
  resources:
    requests:
      cpu: "100m"
      memory: "128Mi"
    limits:
      cpu: "200m"
      memory: "256Mi"

##################################
# Alertmanager disabled
##################################
alertmanager:
  enabled: false

##################################
# Disable default rules (reduce noise)
##################################
defaultRules:
  create: false

EOF
  ]
}

##################################
# Dashboard 1: Cluster Overview
##################################
resource "kubernetes_config_map_v1" "dashboard_overview" {
  depends_on = [helm_release.prometheus]

  metadata {
    name      = "grafana-dashboard-overview"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "overview.json" = <<EOF
{
  "title": "Kubernetes Overview",
  "panels": [
    {
      "type": "stat",
      "title": "Total Pods",
      "targets": [{ "expr": "count(kube_pod_info)" }]
    },
    {
      "type": "stat",
      "title": "Running Pods",
      "targets": [{ "expr": "count(kube_pod_status_phase{phase=\\"Running\\"})" }]
    },
    {
      "type": "graph",
      "title": "CPU Usage",
      "targets": [{
        "expr": "sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace)",
        "legendFormat": "{{namespace}}"
      }]
    }
  ],
  "schemaVersion": 16
}
EOF
  }
}

##################################
# Dashboard 2: Pod Health
##################################
resource "kubernetes_config_map_v1" "dashboard_pods" {
  depends_on = [helm_release.prometheus]

  metadata {
    name      = "grafana-dashboard-pods"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "pods.json" = <<EOF
{
  "title": "Pod Health",
  "panels": [
    {
      "type": "graph",
      "title": "Restarts",
      "targets": [{
        "expr": "increase(kube_pod_container_status_restarts_total[5m])",
        "legendFormat": "{{pod}}"
      }]
    },
    {
      "type": "graph",
      "title": "Memory",
      "targets": [{
        "expr": "sum(container_memory_usage_bytes) by (pod)",
        "legendFormat": "{{pod}}"
      }]
    }
  ],
  "schemaVersion": 16
}
EOF
  }
}
