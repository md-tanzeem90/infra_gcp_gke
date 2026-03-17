# providers.tf

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

# ✅ Kubernetes Provider
provider "kubernetes" {
  host                   = module.gke.cluster_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  # ensures cluster exists before provider init
  experiments {
    manifest_resource = true
  }
}

# ✅ Helm Provider (reuse same config)
provider "helm" {
  kubernetes {
    host                   = module.gke.cluster_endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
   # ensures cluster exists before provider init
  experiments {
    manifest_resource = true
  }
}
