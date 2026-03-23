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


resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com"
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
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
  source = "./modules/cloudsql"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment

  db_password = var.db_password
}

module "redis" {
  source = "./modules/redis"

  environment = var.environment
  project_id  = var.project_id
  region      = var.region
  network     = module.network.vpc_name
}
