# Modern Application Infrastructure on GCP using Terraform

Production-ready Terraform infrastructure for deploying modern cloud-native applications on Google Cloud Platform.

This repository provides a reusable infrastructure foundation for running scalable containerized workloads using Google Kubernetes Engine (GKE) along with supporting services such as Cloud SQL and Redis with monitoring capabilities enabled for Site relibility engineering.

The infrastructure is designed to support workloads including:

•	Web applications
•	API platforms
•	Microservices architectures
•	Background workers
•	Data processing services

---

# Architecture Diagram

Internet
                    │
            Cloud Load Balancer
                    │
              Google Kubernetes Engine
        ┌────────────┼────────────┐
        │            │            │
     Web Apps      APIs        Workers
        │
        │
   Cloud SQL (PostgreSQL)
        │
        │
   Redis (Cache / Queue)

---
# Architecture Overview

The Terraform configuration creates the following components:

* VPC Network
* Subnet for application workloads
* Google Kubernetes Engine (GKE) cluster
* Cloud SQL PostgreSQL database
* Memorystore Redis instance
* Networking components required for connectivity

                 Internet
                    │
            Cloud Load Balancer
                    │
         Google Kubernetes Engine
        ┌────────────┼────────────┐
        │            │            │
     Web Apps      APIs        Workers
        │
        │
   Cloud SQL (PostgreSQL)
        │
        │
   Redis (Cache / Queue)

  
These services form the core infrastructure for deploying a scalable and modern cloud-native applications.

---
# Quick Start

Deploy the infrastructure quickly using the following steps.
git clone https://github.com/<your-repo>.git
cd terraform/environments/dev

gcloud auth login
gcloud config set project <your-project-id>

terraform init
terraform apply
Once completed the following infrastructure will be created:
•	VPC Network
•	Kubernetes Cluster (GKE)
•	Cloud SQL PostgreSQL instance
•	Redis cache instance

---

# Repository Structure

```
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
```

### modules

Reusable Terraform modules defining infrastructure components such as:
•	Networking
•	Kubernetes clusters
•	Databases
•	Caching services
These modules are designed to be reused across multiple environments.
environments
Environment-specific configurations such as:
•	development
•	staging
•	production
Each environment composes modules to create the required infrastructure.

### Prerequisites

Ensure the following tools are installed before running this project:
•	Terraform
•	Google Cloud SDK
•	kubectl
•	Git
You must also have an existing Google Cloud project with sufficient permissions to create infrastructure resources.

---

# Prerequisites

Before running this project ensure the following tools are installed:

* Terraform
* Google Cloud SDK
* kubectl
* Git

You must also have a Google Cloud project created.

---

# Setup

Authenticate with Google Cloud:

```
gcloud auth login
gcloud config set project proj-ecom-dev
```

Enable required APIs:

```
gcloud services enable \
container.googleapis.com \
compute.googleapis.com \
sqladmin.googleapis.com \
redis.googleapis.com \
servicenetworking.googleapis.com
```

---

# Deployment

Navigate to the environment directory:

```
cd terraform/environments/dev
```

Initialize Terraform:

```
terraform init
```

Review the plan:

```
terraform plan
```

Apply the infrastructure:

```
terraform apply
```

---

# Destroy Infrastructure

To remove all resources created by Terraform:

```
terraform destroy
```

---

# Notes

The `.terraform` directory and Terraform state files are excluded from Git using `.gitignore`.

Terraform downloads providers automatically during initialization.

---

# Future Improvements

* Add Helm deployment for the ecommerce application
* Configure Ingress and TLS
* Implement CI/CD pipelines
* Add monitoring and logging

---

# Author

Tanzeem
