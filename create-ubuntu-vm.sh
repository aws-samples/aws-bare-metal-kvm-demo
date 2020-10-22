#!/bin/bash

# Creating the disk
qemu-img create -f qcow2 -o preallocation=metadata,lazy_refcounts=on ${PWD}/vms/ubuntu-01.qcow2 20G

# Spin Up virtual machine
virt-install --connect qemu:///system  \
--nographics \
--os-type linux \
--accelerate \
--hvm \
--network network=default,model=virtio \
--name ubuntu-01 \
--location http://us.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/ \
--extra-args "console=ttyS0 ks=http://files.programster.org/kvm-kickstart-files/ubuntu-18-04.txt" \
--disk ${PWD}/vms/ubuntu-01.qcow2,bus=virtio,format=qcow2 \
--ram 1024 \
--vcpus 2