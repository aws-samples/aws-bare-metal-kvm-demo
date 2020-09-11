#!/bin/bash

export VM_NAME="ubuntu-01" && export NETWORK_NAME="default"

# You can check the range of your subnet here
sudo virsh net-list
sudo virsh net-dumpxml ${NETWORK_NAME}

# Getting the MAC Address of a VM
sudo virsh dumpxml ${VM_NAME} | grep -i '<mac'

# <host mac='52:54:00:95:d2:7b' name='ubuntu-05' ip='192.168.111.12'/>

# Adding a IP Address to VM
sudo virsh net-edit ${NETWORK_NAME}

virsh net-destroy default
virsh net-start default


sudo virsh shutdown ${VM_NAME}
sudo systemctl stop libvirtd && sudo systemctl start libvirtd
sudo virsh start ${VM_NAME}