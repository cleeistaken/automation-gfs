#!/bin/bash 

# Configure the systems
ansible-playbook \
  -i ../config/inventory.yml \
  all.yml
