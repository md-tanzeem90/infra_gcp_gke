provider "kubernetes" {
  host                   = google_container_cluster.dev.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.dev.master_auth[0].cluster_ca_certificate
  )
}
