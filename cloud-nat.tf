
module "cloudnat-vpc-module" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = var.gcp_project_id # Replace this with your project ID in quotes
  network_name = "cloudnat-${var.gcp_region}-${random_id.my_hex.hex}"
  mtu          = 1460

  subnets = [
    {
      subnet_name   = "${var.gcp_region}-subnet-192"
      subnet_ip     = "192.168.1.0/24"
      subnet_region = var.gcp_region
    }
  ]
}

resource "google_compute_firewall" "rules" {
  project = var.gcp_project_id
  name    = "allow-ssh-${var.gcp_region}-${random_id.my_hex.hex}"
  network = module.cloudnat-vpc-module.network_name # Replace with a reference or self link to your network, in quotes

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_router" "router" {
  project = var.gcp_project_id
  name    = "nat-router-${var.gcp_region}-${random_id.my_hex.hex}"
  network = module.cloudnat-vpc-module.network_name
  region  = var.gcp_region
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 2.0"
  project_id                         = var.gcp_project_id
  region                             = var.gcp_region
  router                             = google_compute_router.router.name
  name                               = "nat-config-${var.gcp_region}-${random_id.my_hex.hex}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_instance" "cloud_nat_trial_vm" {
  project                   = var.gcp_project_id
  zone                      = var.gcp_zone
  name                      = "trial-nat-${var.gcp_zone}-${random_id.my_hex.hex}"
  machine_type              = var.gcp_compute_type
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = var.gcp_compute_image
    }
  }
  network_interface {
    network    = module.cloudnat-vpc-module.network_name
    subnetwork = module.cloudnat-vpc-module.subnets_ids[0]
  }
}