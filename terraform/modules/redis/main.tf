resource "google_redis_instance" "redis" {
  name           = "redis"
  region         = var.region
  tier           = "BASIC"
  memory_size_gb = 1

  redis_version = "REDIS_6_X"

  authorized_network = var.network
}