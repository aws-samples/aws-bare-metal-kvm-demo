#!/bin/bash
# Creating windows VM

#Downloading windows drivers
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.189-1/virtio-win-0.1.189.iso

echo "Where is your ISO windows file? "
read ISO_PATH

# Creating disk
qemu-img create -f qcow2 -o preallocation=metadata,lazy_refcounts=on $PWD/vms/windows-01.qcow2 50G

# Starting virtual machine
virt-install --connect qemu:///system  \
--graphics vnc,listen=0.0.0.0,port=5904 \
--os-type windows \
--hvm \
--network bridge=virbr0 \
--name windows-01 \
--disk $PWD/vms/windows-01.qcow2,bus=virtio,format=qcow2 \
--disk $PWD/$ISO_PATH,device=cdrom,bus=ide \
--disk $PWD/virtio-win-0.1.189.iso,device=cdrom,bus=ide \
--ram 2048 \
--vcpus 4 \
--check all=off \
--accelerate



