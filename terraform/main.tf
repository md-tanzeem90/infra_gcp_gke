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
  source = "./modules/network"

  environment = var.environment
  project_id  = var.project_id
  region      = var.region
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

  project_id  = var.project_id
  region      = var.region
  environment = var.environment

  db_password = var.db_password
}

module "redis" {
  source = "../../modules/redis"

  environment = var.environment
  project_id  = var.project_id
  region      = var.region
  network = module.network.vpc_name
}
