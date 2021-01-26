resource "google_compute_network" "network" {
  name = "${var.namespace}-${var.environment}-vpc"

  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "private_subnet" {
  name = "subnet-private-01"

  ip_cidr_range = "10.194.0.0/20"
  network       = google_compute_network.network.id
  region        = var.region
  secondary_ip_range = [
    {
      ip_cidr_range = "10.194.16.0/20"
      range_name    = "pods"
    },
    {
      ip_cidr_range = "10.194.32.0/20"
      range_name    = "services"
    },
  ]
}
