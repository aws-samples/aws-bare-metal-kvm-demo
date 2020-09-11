#!/bin/bash

KVM_USER="kvm_user"

sudo apt-get update -y
sudo apt-get install cpu-checker -y
kvm-ok
sudo apt-get install qemu-kvm libvirt-bin bridge-utils virtinst -y

# Creating KVM user and adding to group
sudo useradd -d /home/$KVM_USER -m $KVM_USER
sudo passwd $KVM_USER
echo "$KVM_USER  ALL=(ALL:ALL) ALL" | sudo tee --append /etc/sudoers

# Adding kvm_user to group
sudo usermod --append --groups libvirt $KVM_USER
# su $KVM_USER

sudo virsh -c qemu:///system list

# Stopping and starting libvirtd
sudo systemctl enable libvirtd && sudo systemctl start libvirtd

# Install helper script to setup new VM's
# Firnd VM IP
# virsh net-list
# virsh net-info default
# virsh net-dhcp-leases default