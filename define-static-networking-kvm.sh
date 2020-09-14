#!/bin/bash

echo "What vitual machine? "
read VM_NAME
# VM_NAME="ubuntu-01"
NETWORK_NAME="default"

# Getting the MAC Address of a VM
MAC_ADDRESS=$(sudo virsh dumpxml ${VM_NAME} | grep -i '<mac address=' | cut -d \' -f2)
IP_ADDRESS=$(sudo virsh net-dhcp-leases default | grep -i ${MAC_ADDRESS} | cut -d ' ' -f13 | cut -d '/' -f1)
# <host mac='52:54:00:95:d2:7b' name='ubuntu-05' ip='192.168.111.12'/>


echo "Line to add:"
echo "<host mac='${MAC_ADDRESS}' name='${VM_NAME}' ip='${IP_ADDRESS}'/>"
# Adding a IP Address to VM
# sudo virsh net-edit ${NETWORK_NAME}

# virsh net-destroy default
# virsh net-start default


# sudo virsh shutdown ${VM_NAME}
# sudo systemctl stop libvirtd && sudo systemctl start libvirtd
# sudo virsh start ${VM_NAME}