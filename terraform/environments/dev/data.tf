# data.tf
data "google_container_cluster" "mycluster" {
  name     = "ecom-dev-cluster"     # Replace with your cluster name
  location = "us-central1"    # Replace with your cluster zone
  project  = "proj-ecom-dev"    # Your GCP project
}

data "google_client_config" "default" {}
