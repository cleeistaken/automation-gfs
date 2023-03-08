#cloud-config
# https://cloudinit.readthedocs.io/en/latest/topics/modules.html
ssh_pwauth: true
users:
  - name: ${username}
    primary_group: ${primary_group}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: ${groups}
    shell: ${shell}
    ssh_import_id: None
    lock_passwd: false
    passwd: ${password}
    ssh_authorized_keys:
      ${ssh_key_list}
