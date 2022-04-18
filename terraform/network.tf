locals {
  networks = {
    jenkins = "10.65.61.0/24"
    gke = "10.9.0.0/24"
  }
}

# TODO: Create VPC
resource "google_compute_network" "network" {
  count = length(keys(local.networks))
  name = "asaf-${element(keys(local.networks), count.index)}-network"
  auto_create_subnetworks = false
}

# TODO: Create Subnet
resource "google_compute_subnetwork" "subnetwork" {
  count = length(keys(local.networks))
  name = "asaf-${element(keys(local.networks), count.index)}-subnetwork"
  ip_cidr_range = element(values(local.networks), count.index)
  network = google_compute_network.network[count.index].id
}

resource "google_compute_address" "static" {
  name = "jenkins-public-ip"
}

resource "google_compute_firewall" "default" {
  name    = "jenkins-firewall"
  network = google_compute_network.network[1].name
  description = "Allow Asaf Personal IP to access Jenkins"

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = ["84.229.137.37/32"]
}