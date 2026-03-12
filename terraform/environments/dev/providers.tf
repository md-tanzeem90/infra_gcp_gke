# providers.tf
provider "kubernetes" {
  host                   = data.google_container_cluster.mycluster.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.mycluster.master_auth[0].cluster_ca_certificate
  )
}
