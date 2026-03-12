E-Commerce Infrastructure on GCP using Terraform

This repository contains Terraform code to provision the infrastructure required to run an e-commerce platform on Google Cloud Platform.

The infrastructure provisions a Kubernetes environment along with supporting services required by a modern ecommerce stack.

Architecture Overview

The Terraform configuration creates the following components:

VPC Network

Subnet for application workloads

Google Kubernetes Engine (GKE) cluster

Cloud SQL PostgreSQL database

Memorystore Redis instance

Networking components required for connectivity

These services form the core infrastructure for deploying a scalable ecommerce application such as Saleor.

Repository Structure
terraform/
 ├── modules/
 │   ├── network/
 │   ├── gke/
 │   ├── cloudsql/
 │   └── redis/
 │
 └── environments/
     └── dev/
         ├── main.tf
         ├── variables.tf
         └── terraform.tfvars
modules

Reusable Terraform modules for each infrastructure component.

environments

Environment-specific configurations such as development, staging, or production.

Prerequisites

Before running this project ensure the following tools are installed:

Terraform

Google Cloud SDK

kubectl

Git

You must also have a Google Cloud project created.

Setup

Authenticate with Google Cloud:

gcloud auth login
gcloud config set project proj-ecom-dev

Enable required APIs:

gcloud services enable \
container.googleapis.com \
compute.googleapis.com \
sqladmin.googleapis.com \
redis.googleapis.com \
servicenetworking.googleapis.com
Deployment

Navigate to the environment directory:

cd terraform/environments/dev

Initialize Terraform:

terraform init

Review the plan:

terraform plan

Apply the infrastructure:

terraform apply
Destroy Infrastructure

To remove all resources created by Terraform:

terraform destroy
Notes

The .terraform directory and Terraform state files are excluded from Git using .gitignore.
Terraform downloads providers automatically during initialization.

Future Improvements

Add Helm deployment for the ecommerce application

Configure Ingress and TLS

Implement CI/CD pipelines

Add monitoring and logging

Author

Tanzeem
# infra_gcp_gke
