# GFS2 on vSphere with vSAN

This folder contains the Terraform code to create the required vSphere infrastructure
and VM for the GFS2 automation.

## Changes

### 2023/03/08
* Major rework to simplify the code
* Switch to cloud-init VM initialization
* Convert local-ip script from bash to Python
