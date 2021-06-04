#!/usr/bin/env bash

# Enable the APIs
gcloud config set project ${TF_VAR_project_id}
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com

# Init if you haven't already
terraform init

# Deploy cluster
terraform apply -auto-approve

# Configure kubectl
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)

# Install ZoneMinder