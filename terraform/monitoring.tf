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
# Prometheus + Grafana (Autopilot SAFE + WIRED)
##################################
resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace_v1.monitoring]

  name       = "prometheus"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  ##################################
  # Stability (CRITICAL)
  ##################################
  timeout         = 1200
  wait            = false
  atomic          = false
  cleanup_on_fail = false
  replace         = false

  values = [
    <<EOF
##################################
# Disable heavy / blocked components
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
# Disable webhook (FIX TIMEOUT)
##################################
prometheusOperator:
  admissionWebhooks:
    enabled: false

##################################
# Prometheus (lightweight)
##################################
prometheus:
  prometheusSpec:
    replicas: 1
    retention: "6h"

    resources:
      requests:
        cpu: "50m"
        memory: "128Mi"
      limits:
        cpu: "200m"
        memory: "256Mi"

##################################
# Grafana (FULLY WIRED)
##################################
grafana:
  enabled: true

  adminUser: admin
  adminPassword: admin123

  service:
    type: LoadBalancer

  resources:
    requests:
      cpu: "25m"
      memory: "64Mi"
    limits:
      cpu: "100m"
      memory: "128Mi"

  ##################################
  # Datasource (AUTO)
  ##################################
  additionalDataSources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090
      isDefault: true

  ##################################
  # Dashboard auto-provisioning
  ##################################
  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard

  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
        - name: default
          orgId: 1
          folder: ""
          type: file
          options:
            path: /var/lib/grafana/dashboards

##################################
# kube-state-metrics (required)
##################################
kubeStateMetrics:
  resources:
    requests:
      cpu: "25m"
      memory: "64Mi"
    limits:
      cpu: "50m"
      memory: "128Mi"

##################################
# Disable default rules
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
