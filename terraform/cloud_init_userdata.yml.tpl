# cloud-config
# https://cloudinit.readthedocs.io/en/latest/topics/modules.html
#
# Note: The default user is required for cloud-final.
# Ref. https://serverfault.com/questions/804304/cloud-init-fails-on-ssh-authkey-fingerprints-module
#
ssh_pwauth: true
users:
  - default
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
