## Confluent Platform Terraform for VMWare
Deploy VMs into VSphere cluster for Confluent Platform


### Prerequisites
* Terraform v0.12.24


### Instructions

Edit the `terraform.tfvars` file with the specifics for user/pass cluster name etc...

Run `terraform plan` and check the output to validate what's going to happen

Run `terraform apply` to create the resources. 