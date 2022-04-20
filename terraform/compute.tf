resource "google_compute_instance" "instance" {
  name = "jenkins-master"
  machine_type = "e2-medium"
  zone = "europe-west3-a"
  tags = ["jenkins-master"]

  boot_disk {
    auto_delete = false
    initialize_params {
      image = "centos-stream-8-v20220406"
    }
  }

  network_interface {
    network = google_compute_network.network[1].self_link
    subnetwork = google_compute_subnetwork.subnetwork[1].self_link

    access_config {
        nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    name = "Jenkins-Master" 
  }

  metadata_startup_script = <<EOF
#!/bin/bash
dnf install java-11-openjdk -y
curl -o /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
dnf install jenkins -y
systemctl start jenkins && systemctl enable jenkins
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io
systemctl start docker
  EOF
  
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "42376560169-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

locals {
  master_authorized_networks_config = [
    {
        cidr_blocks : [
            {
                cidr_block = "34.159.197.88/32"
                display_name = "Jenkins Instance"
            },
            {
                cidr_block = "84.229.137.37/32"
                display_name = "Asaf Personal IP"
            }
        ]
    }
  ]
}

## GKE Cluster ##
resource "google_container_cluster" "primary" {
  name               = "asaf-gke-cluster"
  location           = "europe-west3-a"
  initial_node_count = 1

  dynamic "master_authorized_networks_config" {
    for_each = local.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }

  ip_allocation_policy {}
     
  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = "42376560169-compute@developer.gserviceaccount.com"
    disk_size_gb = 20
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      name = "asaf-gke-cluster"
    }
    tags = ["asaf-gke-controlplane"]

  }

  network = google_compute_network.network[0].self_link
  subnetwork = google_compute_subnetwork.subnetwork[0].self_link

  timeouts {
    create = "30m"
    update = "40m"
  }
}