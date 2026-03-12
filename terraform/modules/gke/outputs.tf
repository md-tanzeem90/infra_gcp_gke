output "cluster_endpoint" {
  value = google_container_cluster.dev.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.dev.master_auth[0].cluster_ca_certificate
}

output "cluster_name" {
  value = google_container_cluster.dev.name
}
