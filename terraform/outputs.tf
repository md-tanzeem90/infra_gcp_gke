output "postgres_ip" {
  value = module.cloudsql.db_ip
}

output "redis_host" {
  value = module.redis.redis_host
}