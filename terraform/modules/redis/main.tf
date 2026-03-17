resource "google_redis_instance" "redis" {
  name           = "ecom-${var.environment}-redis"
  project        = var.project_id
  region         = var.region

  tier           = "BASIC"
  memory_size_gb = var.environment == "prod" ? 4 : 1

  redis_version = "REDIS_6_X"

  # ✅ Use VPC in same project
  authorized_network = var.network

  display_name = "Redis ${var.environment}"

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  lifecycle {
    prevent_destroy = var.environment == "prod" ? true : false
  }
}
