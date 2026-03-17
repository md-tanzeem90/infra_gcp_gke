resource "google_compute_network" "vpc" {
  name                    = "ecom-${var.environment}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "ecom-${var.environment}-subnet"
  ip_cidr_range = local.subnet_cidr
  region        = var.region
  project       = var.project_id
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = local.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = local.services_cidr
  }
}
