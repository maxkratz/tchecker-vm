#!/bin/bash

set -e

#
# Utils
#

# Displays the given input including "=> " on the console.
log () {
	echo "=> $1"
}

#
# Script
#

if [[ $EUID -ne 0 ]]; then
    log "This script must be run as root."
    exit 1
fi

# download Debian image
if [ ! -f debian-13-generic-amd64.qcow2 ]; then
    log "Downloading Debian image."
    wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2
else
    log "Download skipped. Using local image."
fi
# log "Copying Debian image to libvirt image folder."
# cp debian-13-generic-amd64.qcow2 /var/lib/libvirt/images/

# create VM and start provisioning
log "Start VM provisioning."
virt-install --name tchecker --memory 8192 --vcpus 4 --disk=size=10,backing_store=${PWD}/debian-13-generic-amd64.qcow2 --cloud-init user-data=./cloud-init.yaml,disable=on --network bridge=virbr0,mac=52:54:00:fa:58:c8 --osinfo=debian13
# ^the VM terminates itself after provisioning

# create OVA template
log "Create OVA template."
qemu-img convert -p -f qcow2 -O vmdk /var/lib/libvirt/images/tchecker.qcow2 tchecker-disk001.vmdk
tar -cvf tchecker.ova tchecker.ovf tchecker-disk001.vmdk

# fixes permissions
chown -R 1000:1000 debian-13-generic-amd64.qcow2 tchecker-disk001.vmdk tchecker.ova

log "Finished."
