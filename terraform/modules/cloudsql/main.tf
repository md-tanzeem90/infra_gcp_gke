resource "google_sql_database_instance" "postgres" {
  name             = "postgres"
  region           = var.region
  database_version = "POSTGRES_14"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "postgres_db" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "db_user" {
  name     = "db_user"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}
