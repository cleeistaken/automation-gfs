#
# Cluster
#
data "vsphere_datacenter" "vs_dc" {
  name = var.vsphere_cluster.vs_dc
}

data "vsphere_compute_cluster" "vs_cc" {
  name          = var.vsphere_cluster.vs_cls
  datacenter_id = data.vsphere_datacenter.vs_dc.id
}

resource "vsphere_resource_pool" "vs_rp" {
  name                    = var.gfs_resource_pool
  parent_resource_pool_id = data.vsphere_compute_cluster.vs_cc.resource_pool_id
}

data "vsphere_datastore" "vs_ds" {
  name          = var.vsphere_cluster.vs_ds
  datacenter_id = data.vsphere_datacenter.vs_dc.id
}

data "vsphere_storage_policy" "vs_ds_policy" {
  name = var.vsphere_cluster.vs_ds_sp
}

data "vsphere_distributed_virtual_switch" "vs_dvs" {
  name          = var.vsphere_cluster.vs_dvs
  datacenter_id = data.vsphere_datacenter.vs_dc.id
}

data "vsphere_network" "vs_dvs_pg_public" {
  name                            = var.vsphere_cluster.vs_dvs_pg_1
  datacenter_id                   = data.vsphere_datacenter.vs_dc.id
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vs_dvs.id
}

data "vsphere_network" "vs_dvs_pg_private" {
  name                            = var.vsphere_cluster.vs_dvs_pg_2
  datacenter_id                   = data.vsphere_datacenter.vs_dc.id
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vs_dvs.id
}

variable "ovf_map" {
  type    = list(string)
  default = ["eth0", "eth1", "eth2", "eth3"]
}

#
# GFS
#
locals {
  gfs_prefix = format("%s-%02d", var.gfs_vm_prefix, (var.vsphere_cluster_index + 1))
}

#
# Shared Disk
#

resource "vsphere_virtual_machine" "gfs_vm_primary" {
  count = 1
  name  = format("%s-%02d", local.gfs_prefix, count.index + 1)

  # VM template
  #guest_id = data.vsphere_virtual_machine.vs_vm_template.guest_id

  # Template boot mode (efi or bios)
  firmware = var.template_boot

  # Resource pool for created VM
  resource_pool_id = vsphere_resource_pool.vs_rp.id

  # Datastore and Storage Policy
  datastore_id      = data.vsphere_datastore.vs_ds.id
  storage_policy_id = data.vsphere_storage_policy.vs_ds_policy.id

  num_cpus = var.gfs_vm.cpu
  memory   = var.gfs_vm.memory_gb * 1024

  network_interface {
    network_id  = data.vsphere_network.vs_dvs_pg_public.id
    ovf_mapping = "eth0"
  }

  dynamic "network_interface" {
    for_each = range(1, 2)
    content {
      network_id  = data.vsphere_network.vs_dvs_pg_private.id
      ovf_mapping = var.ovf_map[network_interface.value]
    }
  }

  # Although it is possible to add multiple disk controllers, there is
  # no way as of v0.13 to assign a disk to a controller. All disks are
  # defaulted to the first controller.
  #scsi_controller_count = min (4, (var.gfs_vm.data_disk_count + 1))

  disk {
    label       = format("%s-%02d-os-disk0", local.gfs_prefix, count.index + 1)
    size        = var.gfs_vm.os_disk_gb
    unit_number = 0
  }

  dynamic "disk" {
    for_each = range(1, var.gfs_vm.data_disk_count + 1)

    content {
      label             = format("%s-%02d-data-disk%02d", local.gfs_prefix, (count.index + 1), disk.value)
      size              = var.gfs_vm.data_disk_gb
      storage_policy_id = data.vsphere_storage_policy.vs_ds_policy.id
      disk_sharing      = "sharingMultiWriter"
      unit_number       = disk.value
      disk_mode         = "independent_persistent"
    }
  }

  clone {
    template_uuid = var.template.id

    customize {
      linux_options {
        host_name = format("%s-%02d", local.gfs_prefix, count.index + 1)
        domain    = var.vsphere_cluster.vs_vm_domain
      }

      network_interface {
        ipv4_address = var.vsphere_cluster.vs_dvs_pg_1_ipv4_ips[count.index]
        ipv4_netmask = regex("/([0-9]{1,2})$", var.vsphere_cluster.vs_dvs_pg_1_ipv4_subnet)[0]
      }

      network_interface {
        ipv4_address = var.vsphere_cluster.vs_dvs_pg_2_ipv4_ips[count.index]
        ipv4_netmask = regex("/([0-9]{1,2})$", var.vsphere_cluster.vs_dvs_pg_2_ipv4_subnet)[0]
      }

      ipv4_gateway    = var.vsphere_cluster.vs_dvs_pg_1_ipv4_gw
      dns_server_list = var.vsphere_cluster.vs_vm_dns
      dns_suffix_list = var.vsphere_cluster.vs_vm_dns_suffix

    }
  }
}

resource "vsphere_virtual_machine" "gfs_vm_secondary" {
  count = var.gfs_vm_count_per_cluster - 1
  name  = format("%s-%02d", local.gfs_prefix, count.index + 2)

  # VM template
  #guest_id = data.vsphere_virtual_machine.vs_vm_template.guest_id

  # Template boot mode (efi or bios)
  firmware = var.template_boot

  # Resource pool for created VM
  resource_pool_id = vsphere_resource_pool.vs_rp.id

  # Datastore and Storage Policy
  datastore_id      = data.vsphere_datastore.vs_ds.id
  storage_policy_id = data.vsphere_storage_policy.vs_ds_policy.id

  num_cpus = var.gfs_vm.cpu
  memory   = var.gfs_vm.memory_gb * 1024

  network_interface {
    network_id  = data.vsphere_network.vs_dvs_pg_public.id
    ovf_mapping = "eth0"
  }

  dynamic "network_interface" {
    for_each = range(1, 2)
    content {
      network_id  = data.vsphere_network.vs_dvs_pg_private.id
      ovf_mapping = var.ovf_map[network_interface.value]
    }
  }

  scsi_controller_count = min (4, (var.gfs_vm.data_disk_count + 1))

  disk {
    label       = format("%s-%02d-os-disk0", local.gfs_prefix, count.index + 1)
    size        = var.gfs_vm.os_disk_gb
    unit_number = 0
  }

  dynamic "disk" {
    for_each = range(1, var.gfs_vm.data_disk_count + 1)

    content {
      attach = true
      datastore_id = data.vsphere_datastore.vs_ds.id
      path = vsphere_virtual_machine.gfs_vm_primary[0].disk[disk.value].path
      label      = format("%s-%02d-data-disk%02d", local.gfs_prefix, (count.index), disk.value)
      disk_sharing      = "sharingMultiWriter"
      unit_number       = disk.value
      controller_type = "scsi"
    }
  }


  clone {
    template_uuid = var.template.id

    customize {
      linux_options {
        host_name = format("%s-%02d", local.gfs_prefix, count.index + 2)
        domain    = var.vsphere_cluster.vs_vm_domain
      }

      network_interface {
        ipv4_address = var.vsphere_cluster.vs_dvs_pg_1_ipv4_ips[count.index + 1]
        ipv4_netmask = regex("/([0-9]{1,2})$", var.vsphere_cluster.vs_dvs_pg_1_ipv4_subnet)[0]
      }

      network_interface {
        ipv4_address = var.vsphere_cluster.vs_dvs_pg_2_ipv4_ips[count.index + 1]
        ipv4_netmask = regex("/([0-9]{1,2})$", var.vsphere_cluster.vs_dvs_pg_2_ipv4_subnet)[0]
      }

      ipv4_gateway    = var.vsphere_cluster.vs_dvs_pg_1_ipv4_gw
      dns_server_list = var.vsphere_cluster.vs_vm_dns
      dns_suffix_list = var.vsphere_cluster.vs_vm_dns_suffix

    }
  }
}

# Anti-affinity rules for GFS VM
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "gfs_vm_anti_affinity_rule" {
  count               = var.gfs_vm_count_per_cluster > 0 ? 1 : 0
  name                = "gfs-vm-anti-affinity-rule"
  compute_cluster_id  = data.vsphere_compute_cluster.vs_cc.id
  virtual_machine_ids = concat(vsphere_virtual_machine.gfs_vm_primary.*.id, vsphere_virtual_machine.gfs_vm_secondary.*.id)
}

