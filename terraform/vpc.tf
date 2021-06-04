variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "credential_file" { 
  description = "Service account credentials file"
  default = "gcloud.json"
}

variable "env_name" { 
  description = "The environment name"
}

provider "google" {
  project = var.project_id
  region  = var.region
  credentials = "${var.credential_file}"
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.env_name}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.env_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}