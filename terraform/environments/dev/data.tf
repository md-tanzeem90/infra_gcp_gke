# data.tf
data "google_project" "project" {}

data "google_container_cluster" "mycluster" {
  name     = "ecom-dev-cluster"     # Replace with your cluster name
  location = "us-central1"    # Replace with your cluster zone
  project  = data.google_project.project.project_id
}

data "google_client_config" "default" {}
