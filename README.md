# F5XC GCP CLOUD CE

Terraform to create F5XC GCP cloud CE

## Usage

- Clone this repo with: `git clone --recurse-submodules https://github.com/cklewar/f5-xc-gcp-ce`
- Enter repository directory with: `cd f5xc-gcp-cloud-ce`
- Obtain F5XC API certificate file from Console and save it to `cert` directory
- Pick and choose from below examples and add mandatory input data and copy data into file `main.tf.example`.
- Rename file __main.tf.example__ to __main.tf__ with: `rename main.tf.example main.tf`
- Initialize with: `terraform init`
- Apply with: `terraform apply -auto-approve` or destroy with: `terraform destroy -auto-approve`

## F5XC GCP Cloud CE single NIC module usage example

````hcl
module "gcp_ce" {
  source                     = "./modules/f5xc/ce/gcp"
  gcp_region                 = var.gcp_region
  machine_type               = var.machine_type
  network_name               = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  ssh_username               = "centos"
  machine_image              = var.machine_image
  instance_name              = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  ssh_public_key             = file(var.ssh_public_key_file)
  machine_disk_size          = var.machine_disk_size
  fabric_subnet_inside       = var.fabric_subnet_inside
  fabric_subnet_outside      = var.fabric_subnet_outside
  host_localhost_public_name = "vip"
  f5xc_tenant                = var.f5xc_tenant
  f5xc_api_url               = var.f5xc_api_url
  f5xc_namespace             = var.f5xc_namespace
  f5xc_api_token             = var.f5xc_api_token
  f5xc_token_name            = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  f5xc_fleet_label           = var.f5xc_fleet_label
  f5xc_cluster_latitude      = var.cluster_latitude
  f5xc_cluster_longitude     = var.cluster_longitude
  f5xc_ce_gateway_type       = "ingress_gateway"
  providers                  = {
    google   = google.default
    volterra = volterra.default
  }
}

output "ce" {
  value = module.gcp_ce.ce
}
````

## F5XC GCP Cloud CE Multi NIC module usage example

````hcl
module "gcp_ce" {
  source                     = "./modules/f5xc/ce/gcp"
  gcp_region                 = var.gcp_region
  machine_type               = var.machine_type
  network_name               = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  ssh_username               = "centos"
  machine_image              = var.machine_image
  instance_name              = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  ssh_public_key             = file(var.ssh_public_key_file)
  machine_disk_size          = var.machine_disk_size
  fabric_subnet_inside       = var.fabric_subnet_inside
  fabric_subnet_outside      = var.fabric_subnet_outside
  host_localhost_public_name = "vip"
  f5xc_tenant                = var.f5xc_tenant
  f5xc_api_url               = var.f5xc_api_url
  f5xc_namespace             = var.f5xc_namespace
  f5xc_api_token             = var.f5xc_api_token
  f5xc_token_name            = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  f5xc_fleet_label           = var.f5xc_fleet_label
  f5xc_cluster_latitude      = var.cluster_latitude
  f5xc_cluster_longitude     = var.cluster_longitude
  f5xc_ce_gateway_type       = "ingress_egress_gateway"
  providers                  = {
    google   = google.default
    volterra = volterra.default
  }
}

output "ce" {
  value = module.gcp_ce.ce
}
````

## F5XC GCP Cloud CE Single NIC existing network module usage example

````hcl
module "gcp_ce" {
  source                         = "./modules/f5xc/ce/gcp"
  gcp_region                     = var.gcp_region
  machine_type                   = var.machine_type
  network_name                   = module.cloudnat-vpc-module.network_name
  ssh_username                   = "centos"
  machine_image                  = var.machine_image
  instance_name                  = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  ssh_public_key                 = file(var.ssh_public_key_file)
  machine_disk_size              = var.machine_disk_size
  # existing_fabric_subnet_inside  = module.cloudnat-vpc-module.subnets_ids[0]
  existing_fabric_subnet_outside = module.cloudnat-vpc-module.subnets_ids[0]
  host_localhost_public_name     = "vip"
  f5xc_tenant                    = var.f5xc_tenant
  f5xc_api_url                   = var.f5xc_api_url
  f5xc_namespace                 = var.f5xc_namespace
  f5xc_api_token                 = var.f5xc_api_token
  f5xc_token_name                = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  f5xc_fleet_label               = var.f5xc_fleet_label
  f5xc_cluster_latitude          = var.cluster_latitude
  f5xc_cluster_longitude         = var.cluster_longitude
  f5xc_ce_gateway_type           = "ingress_gateway"
  providers                      = {
    google   = google.default
    volterra = volterra.default
  }
}

output "ce" {
  value = module.gcp_ce.ce
}
````

## F5XC GCP Cloud CE Single NIC existing network and GCP Cloud NAT module usage example

```hcl
resource "google_service_account" "service_account" {
  account_id   = "${var.project_prefix}-f5xc-${var.project_name}-ce-${var.project_suffix}"
  display_name = "F5 CE Service Account"
  project      = var.gcp_project_id
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = var.gcp_project_id
  network_name = "${var.project_prefix}-${var.project_name}-vpc-${var.gcp_region}-${var.project_suffix}"
  mtu          = 1460

  subnets = [
    {
      subnet_name   = "${var.project_prefix}-${var.project_name}-subnet-192-${var.gcp_region}-${var.project_suffix}"
      subnet_ip     = "192.168.1.0/24"
      subnet_region = var.gcp_region
    }
  ]
}

module "firewall" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.gcp_project_id
  network_name = module.vpc.network_name
  rules        = [
    {
      name                    = "${var.project_prefix}-${var.project_name}-allow-ingress-${var.gcp_region}-${var.project_suffix}"
      priority                = null
      description             = null
      direction               = "INGRESS"
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow                   = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      deny       = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "${var.project_prefix}-${var.project_name}-allow-egress-${var.gcp_region}-${var.project_suffix}"
      priority                = null
      description             = null
      direction               = "EGRESS"
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow                   = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      deny       = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]
}

module "nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 2.0"
  project_id                         = var.gcp_project_id
  region                             = var.gcp_region
  router                             = "${var.project_prefix}-${var.project_name}-nat-router-${var.gcp_region}-${var.project_suffix}"
  create_router                      = true
  name                               = "${var.project_prefix}-${var.project_name}-nat-config-${var.gcp_region}-${var.project_suffix}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  network                            = module.vpc.network_name
}

module "gcp_ce" {
  source                         = "./modules/f5xc/ce/gcp"
  gcp_region                     = var.gcp_region
  machine_type                   = var.machine_type
  network_name                   = module.vpc.network_name
  ssh_username                   = "centos"
  has_public_ip                  = false
  machine_image                  = var.machine_image
  instance_name                  = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  ssh_public_key                 = file(var.ssh_public_key_file)
  machine_disk_size              = var.machine_disk_size
  gcp_service_account_email      = google_service_account.service_account.email
  host_localhost_public_name     = "vip"
  existing_fabric_subnet_outside = module.vpc.subnets_ids[0]
  f5xc_tenant                    = var.f5xc_tenant
  f5xc_api_url                   = var.f5xc_api_url
  f5xc_namespace                 = var.f5xc_namespace
  f5xc_api_token                 = var.f5xc_api_token
  f5xc_token_name                = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  f5xc_fleet_label               = var.f5xc_fleet_label
  f5xc_cluster_latitude          = var.cluster_latitude
  f5xc_cluster_longitude         = var.cluster_longitude
  f5xc_ce_gateway_type           = var.f5xc_ce_gateway_type
  providers = {
    google   = google.default
    volterra = volterra.default
  }
}

output "ce" {
  value = module.gcp_ce.ce
}
```