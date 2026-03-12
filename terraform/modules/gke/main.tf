resource "google_container_cluster" "dev" {
  name     = "ecom-dev-cluster"
  location = "us-central1"

  deletion_protection = false

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
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

  vertical_pod_autoscaling {
    enabled = true
  }
}


data "google_project" "project" {}
