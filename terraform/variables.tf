variable "environment" {
  description = "Environment derived from branch"
  type        = string
}

variable "project_id" {
  description = "Dynamic project id"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "db_password" {
  sensitive = true
}
