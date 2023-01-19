# Notes

1. follow readme

expect it to fail

```sh
## README.md      example
cp main.example.tf main.tf

## Variables
touch terraform.tfvars

## Cert
mkdir cert
cp ~/Downloads/abc.crt ./cert

## Auth
export GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)"
export VES_P12_PASSWORD="asdf"

## Terraform
terraform init
terraform plan
```

### Fails (as expected)

```
│ Error: Error creating instance: googleapi: Error 412: Constraint constraints/compute.vmExternalIpAccess violated for project 974404398142. Add instance projects/caseyproject/zones/us-east4-c/instances/f5xc-gcp-ce-01 to the constraint to use external IP with it., conditionNotMet
│
│   with module.gcp_ce.module.node[0].google_compute_instance.instance,
│   on modules/f5xc/ce/gcp/nodes/main.tf line 1, in resource "google_compute_instance" "instance":
│    1: resource "google_compute_instance" "instance" {
  ```

2.  MOdifications

  - now with nat
  - modify out

__modules/f5xc/ce/gcp/main.tf__

```hcl
resource "volterra_token" "site" {
  name      = var.f5xc_token_name
  namespace = var.f5xc_namespace
}

locals {
  create_network = var.fabric_subnet_outside != "" || (var.fabric_subnet_inside != "" && var.fabric_subnet_outside != "") ? true : false
}

# module "network" {
#   count                 = local.create_network ? (var.f5xc_ce_gateway_multi_node ? 2 : 1) : 0
#   source                = "./network"
#   gcp_region            = var.gcp_region
#   network_name          = var.network_name
#   fabric_subnet_outside = var.fabric_subnet_outside
#   fabric_subnet_inside  = var.fabric_subnet_inside
#   f5xc_ce_gateway_type  = var.f5xc_ce_gateway_type
# }

module "config" {
  count                      = var.f5xc_ce_gateway_multi_node ? 2 : 1
  source                     = "./config"
  instance_name              = var.instance_name
  volterra_token             = volterra_token.site.id
  cluster_labels             = local.cluster_labels
  ssh_public_key             = var.ssh_public_key
  host_localhost_public_name = var.host_localhost_public_name
  f5xc_ce_gateway_type       = var.f5xc_ce_gateway_type
  f5xc_cluster_latitude      = var.f5xc_cluster_latitude
  f5xc_cluster_longitude     = var.f5xc_cluster_longitude
}

# module "node" {
#   count                       = var.f5xc_ce_gateway_multi_node ? 2 : 1
#   source                      = "./nodes"
#   machine_type                = var.machine_type
#   ssh_username                = var.ssh_username
#   machine_image               = var.machine_image
#   instance_name               = var.instance_name
#   sli_subnetwork              = var.fabric_subnet_inside
#   slo_subnetwork              = var.fabric_subnet_outside
#   ssh_public_key              = var.ssh_public_key
#   machine_disk_size           = var.machine_disk_size
#   f5xc_tenant                 = var.f5xc_tenant
#   f5xc_api_url                = var.f5xc_api_url
#   f5xc_api_token              = var.f5xc_api_token
#   f5xc_namespace              = var.f5xc_namespace
#   f5xc_ce_user_data           = module.config[0].ce["master-${count.index}"]["user_data"]
#   f5xc_cluster_size           = var.f5xc_cluster_size
#   f5xc_ce_gateway_type        = var.f5xc_ce_gateway_type
#   f5xc_registration_retry     = var.f5xc_registration_retry
#   f5xc_registration_wait_time = var.f5xc_registration_wait_time
# }



resource "random_id" "my_hex" {
  byte_length = 1
}

resource "google_compute_instance" "my_ce_instance" {
  name                      = var.instance_name
  machine_type              = var.machine_type
  allow_stopping_for_update = true
  tags                      = ["ce-${random_id.my_hex.hex}-outside-egress", "ce-${random_id.my_hex.hex}-outside-ingress"]

  boot_disk {
    initialize_params {
      image = var.machine_image
      size  = var.machine_disk_size
    }
  }

  network_interface {
    subnetwork = var.fabric_subnet_inside
  }

  metadata = {
    ssh-keys  = "${var.ssh_username}:${var.ssh_public_key}"
    user-data = module.config[0].ce["master-0"]["user_data"]
  }

  service_account {
    email = google_service_account.my_ce_service_account.email

    scopes = ["cloud-platform"]
  }
}

resource "google_service_account" "my_ce_service_account" {
  account_id   = "sa-my-eff-five-ce-${random_id.my_hex.hex}"
  display_name = "Eff Five CE Service Account"
}


resource "google_compute_firewall" "ce_egress" {
  name      = "ce-${random_id.my_hex.hex}-outside-egress"
  network   = var.network_name
  direction = "EGRESS"
  allow {
    protocol = "udp"
    ports    = ["4500"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]

  }

  target_tags = ["ce-${random_id.my_hex.hex}-outside-egress"]
}
resource "google_compute_firewall" "ce_ingress" {
  name      = "ce-${random_id.my_hex.hex}-outside-ingress"
  network   = var.network_name
  direction = "INGRESS"

  allow {
    protocol = "udp"
    ports    = ["4500"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]

  }
  target_tags = ["ce-${random_id.my_hex.hex}-outside-ingress"]


  source_ranges = [
    "5.182.215.0/25",
    "84.54.61.0/25",
    "23.158.32.0/25",
    "84.54.62.0/25",
    "185.94.142.0/25",
    "185.94.143.0/25",
    "159.60.190.0/24"
  ]
}
```