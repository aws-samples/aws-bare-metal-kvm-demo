#!/bin/bash

KVM_USER="kvm_user"

echo "Updating S.O"
sudo apt-get update -y > /dev/null 2>&1
echo
# Verifying if Instance has support for virtualization
echo "Installing CPU-Checker..."
sudo apt-get install cpu-checker -y > /dev/null 2>&1
kvm-ok
echo
echo "Installing KVM..."
# Instalation
sudo apt-get install qemu-kvm libvirt-bin bridge-utils virtinst -y > kvm-install.log 2>&1
echo

# Creating KVM user and adding to group
echo "Creating ${KVM_USER}"
sudo useradd -d /home/$KVM_USER -m $KVM_USER
echo "Please define kvm_user password:"
# Defining user password
sudo passwd $KVM_USER
echo "$KVM_USER  ALL=(ALL:ALL) ALL" | sudo tee --append /etc/sudoers
echo

# Adding kvm_user to group
sudo usermod --append --groups libvirt $KVM_USER

# Listing VM's
echo "Listing VM's"
sudo virsh -c qemu:///system list

# Stopping and starting libvirtd
sudo systemctl enable libvirtd && sudo systemctl start libvirtd

# Install helper script to setup new VM's
# Firnd VM IP
# virsh net-list
# virsh net-info default
# virsh net-dhcp-leases default