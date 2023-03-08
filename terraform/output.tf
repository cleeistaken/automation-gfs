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
