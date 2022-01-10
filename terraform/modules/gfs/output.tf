output "gfs_env" {
  value = {
    "cluster_id" = var.vsphere_cluster_index + 1
    "cluster" = {
      "gfs_primary" = vsphere_virtual_machine.gfs_vm_primary
      "gfs_secondary" = vsphere_virtual_machine.gfs_vm_secondary
    }
  }
}