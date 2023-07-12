#! /bin/bash

# Nasty bug
# Ref. https://github.com/pypa/pipenv/issues/5075
echo "Exporting SETUPTOOLS_USE_DISTUTILS"
export SETUPTOOLS_USE_DISTUTILS=stdlib
export ANSIBLE_CONFIG=./config/ansible.cfg

echo "Running host configurations"
pipenv run ansible-playbook -i ./config/inventory.yml ansible/main.yml
