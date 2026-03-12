output "db_instance_connection_name" {
  value = google_sql_database_instance.saleor_postgres.connection_name
}

output "db_ip" {
  value = google_sql_database_instance.saleor_postgres.public_ip_address
}