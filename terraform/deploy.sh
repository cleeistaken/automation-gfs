#! /bin/bash

terraform init

terraform apply \
-auto-approve \
--var-file=../../config/terraform.tfvars.gfs \
--var-file=../config/terraform.tfvars \
--var-file=../config/terraform-gfs.tfvars
