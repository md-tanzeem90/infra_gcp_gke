terraform {
  backend "gcs" {
    bucket = "proj-ecom-terraform-state"
    prefix = "infra_gke/${var.environment}"
  }
}
