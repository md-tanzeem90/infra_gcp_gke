terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "proj-ecom-dev"
  region  = "us-central1"
  #credentials = file("C:/Users/mohpasha2/.gcp/terraform-key.json")
}

module "network" {
  source = "../../modules/network"
}

module "gke" {
  source     = "../../modules/gke"
  network    = module.network.vpc_name
  subnetwork = module.network.subnet_name
}

module "cloudsql" {
  source = "../../modules/cloudsql"

  region      = "us-central1"
  db_password = "ChangeThisPassword123"
}

module "redis" {
  source = "../../modules/redis"

  region  = "us-central1"
  network = module.network.vpc_id
}