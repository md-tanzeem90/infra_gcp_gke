variable "environment" {
  description = "Environment name derived from branch"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "network" {
  description = "VPC network"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork"
  type        = string
}
