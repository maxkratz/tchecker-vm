#!/bin/bash

# Careful: I did not test this script, yet.

set -e

# download Debian image
wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2
sudo cp debian-13-generic-amd64.qcow2 /var/lib/libvirt/images/

# create VM and start provisioning
virt-install --name tchecker --memory 8192 --vcpus 4 --disk=size=10,backing_store=/var/lib/libvirt/images/debian-13-generic-amd64.qcow2 --cloud-init user-data=./cloud-init.yaml,disable=on --network bridge=virbr0,mac=52:54:00:fa:58:c8 --osinfo=debian13
# ^the VM terminates itself after provisioning

# create OVA template
# sudo apt-get install -yq qemu-utils
sudo qemu-img convert -p -f qcow2 -O vmdk /var/lib/libvirt/images/tchecker.qcow2 tchecker-disk001.vmdk
tar -cvf tchecker.ova tchecker.ovf tchecker-disk001.vmdk

# fixes permissions
sudo chown -R 1000:1000 .
