#! /bin/bash

TERRAFORM_DIR="1.terraform"
ANSIBLE_SETUP_DIR="2.ansible-setup"
ANSIBLE_GFS_DIR="3.ansible-gfs"

# Terraform
echo "Destroying Virtual Machines"
pushd "$TERRAFORM_DIR"
./destroy.sh
popd
