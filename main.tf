module "gcp_ce" {
  source                     = "./modules/f5xc/ce/gcp"
  gcp_region                 = var.gcp_region
  machine_type               = var.machine_type
  network_name               = module.cloudnat-vpc-module.network_name
  ssh_username               = "centos"
  machine_image              = var.machine_image
  instance_name              = format("%s-%s-%s", var.project_prefix, var.project_name, var.project_suffix)
  ssh_public_key             = file(var.ssh_public_key_file)
  machine_disk_size          = var.machine_disk_size
  fabric_subnet_inside       = module.cloudnat-vpc-module.subnets_ids[0]
  fabric_subnet_outside      = module.cloudnat-vpc-module.subnets_ids[0]
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
  providers = {
    google   = google.default
    volterra = volterra.default
  }
}

output "ce" {
  value = module.gcp_ce.ce
}

resource "random_id" "my_hex" {
  byte_length = 2
}