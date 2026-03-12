output "db_instance_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "db_ip" {
  value = google_sql_database_instance.postgres.public_ip_address
}
