########################################
# Locals (naming convention)
########################################
locals {
  db_instance_name = "postgres-${var.environment}"
  db_name          = "postgres_app_db_${var.environment}"
  db_user          = "db_user_${var.environment}"
}

########################################
# Cloud SQL Instance
########################################
resource "google_sql_database_instance" "postgres" {
  name             = local.db_instance_name
  region           = var.region
  database_version = "POSTGRES_14"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      #  Restrict later (for now open for testing)
      authorized_networks {
        name  = "allow-all-temp"
        value = "0.0.0.0/0"
      }
    }
  }

  deletion_protection = false
}

########################################
# Database
########################################
resource "google_sql_database" "postgres_db" {
  name     = local.db_name
  instance = google_sql_database_instance.postgres.name
}

########################################
# DB User
########################################
resource "google_sql_user" "db_user" {
  name     = local.db_user
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}
