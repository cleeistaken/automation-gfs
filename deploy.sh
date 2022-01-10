#! /bin/bash

TERRAFORM_DIR="terraform"
ANSIBLE_SETUP_DIR="ansible-setup"

# Terraform
echo "Deploying Virtual Machines"
pushd "$TERRAFORM_DIR"
  ./deploy.sh
popd

# Ansible VM Setup
echo "Configuring VM"
pushd "$ANSIBLE_SETUP_DIR"
  ./deploy.sh
popd
