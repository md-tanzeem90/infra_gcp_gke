variable "region" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "environment" {
  description = "Environment derived from branch"
  type        = string
}
