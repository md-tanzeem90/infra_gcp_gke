resource "google_container_cluster" "gke" {
  name     = "ecom-${var.environment}-cluster"
  location = var.region

  project = var.project_id

  deletion_protection = var.environment == "prod" ? true : false

  network    = var.network
  subnetwork = var.subnetwork

  enable_autopilot = true

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  resource_labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}


data "google_project" "project" {
  project_id = var.project_id
}
