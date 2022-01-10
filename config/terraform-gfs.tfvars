#
# Template
#
template_library_name = "Content Library GFS"
template_ova = "centos8.4_x64.ova"
template_name = "Centos 8.4 for GFS"
template_description = "Centos 8.4 for GFS Automation"
template_boot = "efi"

#
# GFS
#
gfs_resource_pool = "gfs"
gfs_vm_prefix = "gfs"
gfs_vm_count_per_cluster = 3

gfs_vm = {
    cpu = 4
    memory_gb = 16
    os_disk_gb = 100
    data_disk_count = 1
    data_disk_gb = 255
}
