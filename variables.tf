variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
  default     = "f5xc"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
  default     = "01"
}

variable "project_name" {
  type    = string
  default = "gcp-ce"
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type    = string
  default = "system"
}

variable "f5xc_api_token" {
  type = string
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "ssh_public_key_file" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "us-east1"
}

variable "gcp_zone" {
  type    = string
  default = "us-east1-b"
}

variable "gcp_project_id" {
  type = string
}

variable "cluster_latitude" {
  type    = string
  default = "39.8282"
}

variable "cluster_longitude" {
  type    = string
  default = "-98.5795"
}

variable "fabric_subnet_outside" {
  type    = string
  default = "192.168.0.0/25"
}

variable "fabric_subnet_inside" {
  type    = string
  default = "192.168.0.128/25"
}

variable "machine_image" {
  type    = string
  default = "vesio-dev-cz/centos7-atomic-202007210749-multi"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-4"
}

variable "machine_disk_size" {
  type    = string
  default = "40"
}

variable "f5xc_ce_gateway_type" {
  type    = string
  default = "ingress_egress_gateway"
}

variable "f5xc_fleet_label" {
  type    = string
  default = "gcp-ce-test"
}

locals {
  cluster_labels = var.f5xc_fleet_label != "" ? { "ves.io/fleet" = var.f5xc_fleet_label } : {}
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
  alias   = "default"
}

provider "volterra" {
  api_p12_file = var.f5xc_api_p12_file
  url          = var.f5xc_api_url
  alias        = "default"
}


variable "gcp_compute_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "gcp_compute_type" {
  type    = string
  default = "e2-small"
}
