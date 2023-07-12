output "ResPool_ID" {
  description = "Resource Pool ID"
  value       = vsphere_resource_pool.my_resource_pool.id
}

output "vm_name" {
  description = "VM name"
  value       = concat(vsphere_virtual_machine.gfs_vm_primary.*.name,
                       vsphere_virtual_machine.gfs_vm_secondary.*.name)
}

output "vm_default_ip" {
  description = "Default IP address of the deployed VM"
  value       = concat(vsphere_virtual_machine.gfs_vm_primary.*.default_ip_address,
                       vsphere_virtual_machine.gfs_vm_secondary.*.default_ip_address)
}

output "vm_guest_ip" {
  description = "All the registered ip address of the VM"
  value       = concat(vsphere_virtual_machine.gfs_vm_primary.*.guest_ip_addresses,
                       vsphere_virtual_machine.gfs_vm_secondary.*.guest_ip_addresses)
}

output "vm_uuid" {
  description = "UUID of the VM in vSphere"
  value       = concat(vsphere_virtual_machine.gfs_vm_primary.*.uuid,
                       vsphere_virtual_machine.gfs_vm_secondary.*.uuid)
}

resource "local_file" "inventory" {
  content  = templatefile("inventory.yml.tpl", {

    # VMS
    vms_primary = vsphere_virtual_machine.gfs_vm_primary
    vms_secondary = vsphere_virtual_machine.gfs_vm_secondary

    # VM credentials
    vm_user = var.cloud_init_username
    vm_ssh_private_key_file = var.rsa_private_key_file

    # vCenter
    vcenter_server = var.vcenter_server
    vcenter_user = var.vcenter_user
    vcenter_password = var.vcenter_password
    vcenter_allow_unverified_ssl = var.vcenter_insecure_ssl

    # vSphere
    vsphere_datacenter = var.vsphere_datacenter
    vsphere_cluster = var.vsphere_compute_cluster

    # GFS
    vm_disk_data_count = var.vm_disk_data_count

    # Automation System
    automation_system_local_ip = data.external.local_ip.result.ip

  })
  filename = "${var.output_folder}/inventory.yml"
  file_permission = "644"
}
