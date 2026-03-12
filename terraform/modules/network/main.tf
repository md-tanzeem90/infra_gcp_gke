resource "google_compute_network" "vpc" {
  name                    = "ecom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dev" {
  name          = "ecom-dev-subnet"
  ip_cidr_range = "10.10.0.0/20"
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }
}