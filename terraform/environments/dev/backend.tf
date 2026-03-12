terraform {
  backend "gcs" {
    bucket  = "proj-ecom-terraform-state"
    prefix  = "infra_gke/state"
  }
}
