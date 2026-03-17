variable "environment" {
  description = "Environment derived from branch"
  type        = string
}

variable "project_id" {
  description = "Dynamic project id"
  type        = string
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "db_password" {
  sensitive = true
}
