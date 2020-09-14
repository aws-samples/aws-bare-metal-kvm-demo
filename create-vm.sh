#!/bin/bash
# Creating windows VM

# Creating disk
qemu-img create -f qcow2 -o preallocation=metadata,lazy_refcounts=on $PWD/windows-03.qcow2 50G

# Creating virtual machine
virt-install --connect qemu:///system  \
--graphics vnc,listen=0.0.0.0,port=5904 \
--os-type windows \
--hvm \
--network bridge=virbr0 \
--name windows-02 \
--disk $PWD/windows-02.qcow2,bus=virtio,format=qcow2 \ # Disk created above
--disk $PWD/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso,device=cdrom,bus=ide \ # Windows image
--disk $PWD/virtio-win-0.1.189.iso,device=cdrom,bus=ide \ # This contains the driver for the drive we’ll be installing Windows on. - https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.189-1/
--ram 2048 \
--vcpus 2 \
--check all=off \
--accelerate