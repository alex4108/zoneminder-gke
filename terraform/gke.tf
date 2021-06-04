# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.env_name}"
  location = var.region
  
  # Auto Pilot!
  enable_autopilot = true

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

}