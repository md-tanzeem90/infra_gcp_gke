terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

locals {
  env        = var.environment
  project_id = var.project_id
}

provider "google" {
  project = local.project_id
  region  = "us-central1"
}

module "network" {
  source = "../../modules/network"
}

module "gke" {
  source = "./modules/gke"

  environment = var.environment
  project_id  = var.project_id
  region      = var.region

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
