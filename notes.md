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

