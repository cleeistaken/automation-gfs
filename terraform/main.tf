#
# vSphere Provider
#
provider "vsphere" {
  vsphere_server = var.vcenter_server
  user = var.vcenter_user
  password = var.vcenter_password
  allow_unverified_ssl = var.vcenter_insecure_ssl
}

#
# Get Local IP
#
data "external" "local_ip" {
  program = ["./get-ip.sh"]
}

#
# Content Library
#
module "template" {
  source = "./modules/template"

  # vSphere Cluster
  vsphere_cluster = var.vsphere_cluster

  # Template
  content_library_name = var.template_library_name
  content_library_item_url = format("http://%s/templates/%s", data.external.local_ip.result.ip, var.template_ova)
  content_library_item_name = var.template_name
  content_library_item_description = var.template_description
}

#
# GFS VM
#
module "gfs" {
  source = "./modules/gfs"

  # Clusters
  vsphere_cluster = var.vsphere_cluster

  # Template
  template = module.template.content_library_item
  template_boot = var.template_boot

  # Prefix for all VM
  gfs_vm_prefix = var.gfs_vm_prefix

  # GFS VM
  gfs_vm_count_per_cluster = var.gfs_vm_count_per_cluster
  gfs_vm = var.gfs_vm
}
