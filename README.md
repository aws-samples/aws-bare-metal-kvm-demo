# aws-bare-metal-kvm

The purpose of this repository is to show virtualization using KVM on a bare metal server on AWS

This type of EC2 Instances offer the best of both worlds, allowing the operacional system to be executed directly on the underlying hardware, at the same time that it provides acess to all of the benefits of the cloud.

[Amazon EC2 Bare Metal Instances](https://aws.amazon.com/blogs/aws/new-amazon-ec2-bare-metal-instances-with-direct-access-to-hardware/)

# Sumary

- [Prerequisites](#prerequisites)
- [Creating our Amazon EC2](#creating-our-amazon-ec2)
- [Installing KVM](#installing-kvm)
- [Creating the first Ubuntu VM ](#creating-the-first-ubuntu-vm)
- [Defining an static IP using the Default network Nat-based networking](#defining-an-static-ip-using-the-default-network-nat-based-networking)
  * [Defining an static IP for our VM](#defining-an-static-ip-for-our-vm)
- [Exposing our VM to external access via IP Tables](#exposing-our-vm-to-external-access-via-ip-tables)
- [Creating our first Windows server](#creating-our-first-windows-server)
  * [Prerequisites](#prerequisites-1)
  * [Creating a Windows VM](#creating-a-windows-vm)
- [References](#references)

# Prerequisites

- Configured Amazon VPC with at least one public subnet

# Creating our Amazon EC2

For this demonstration we will use an EC2 of type: **i3.metal**:

> [i3.metal](https://aws.amazon.com/pt/ec2/instance-types/i3/)

Login to AWS console and select EC2 > instances > Launch Instance

<p align="center"> 
<img src="images/ec2-01.png">
</p>

>Obs: We will use Ubuntu 18.04 as the operational system

Select the instance type i3.large > Configure Instance Details

<p align="center"> 
<img src="images/ec2-02.png">
</p>

Select the VPC and subnet where you want to do the launch of your instance 

>Obs: It will be necessary to accomplish SSH on your instance, therefore realize the launch on a public subnet or have mechanisms to access your instance (VPN/Bastion) 

Select the amount of GB for the Root Volume (We will use this virtual machine to do virtualization, therefore select a proper ammount)

<p align="center"> 
<img src="images/ec2-03.png">
</p>

Define a Name Tag for your EC2

<p align="center"> 
<img src="images/ec2-04.png">
</p>

> Obs: I will use the name kvm-virtualization-lab

Click on **Configure Security Group**

Create a specific Security Group for your EC2 or select one that already exists.

>Obs: Remember to check the necessary ports on the Security Group to do the remote access to our virtual machines

Click on **Review and Launch**

Validate the informations and click on **Launch**

Create a private key .pem in case you don´t have or utilize one that already exists

<p align="center"> 
<img src="images/ec2-05.png">
</p>

Click on **Launch Instance**

Wait a few minutes for your EC2 Instance be ready to be accessed 

<p align="center"> 
<img src="images/ec2-06.png">
</p>

# Installing KVM

In this repository there are some scripts that will help us to accomplish all of the configuration steps.

```bash
ssh -i bare-metal-demo.pem ubuntu@XXX.XXX.XXX.XXX
```

Realize SSH on the server and follow the following steps:


```bash
sudo su - 
```

```bash
cd /opt/ && apt-get update && apt-get install git -y
```

```
git clone https://github.com/BRCentralSA/aws-bare-metal-kvm.git
```

Do the KVM and the necessary components installation 

```
cd aws-bare-metal-kvm && ./install-kvm-ubuntu.sh
```

# Creating the first Ubuntu VM

For this demonstration we will create a Ubuntu 18.04 server with 1GB of RAM and 2 vCpu

```
./create-ubuntu-vm.sh
```

Wait for the creation completion, it can take some time. After completion it will be necessary to login again in the server

A Logon screen will be shown, use the default user and password.

**User:** ubuntu

**Pass:** ubuntu

<p align="center"> 
<img src="images/terminal-01.png">
</p>

Go back to the Host OS and list the VM'ms

```bash
sudo virsh -c qemu:///system list
```

<p align="center"> 
<img src="images/terminal-02.png">
</p>

# Defining an static IP using the Default network Nat-based networking

We will use the **default** network  crated on the KVM instalation process

Using **virsh**

You can create, exclude, execute, stop and manage your virtual machines from the command line, using a tool called virsh. Virsh is mostly useful for advanced Linux administrators, interested ​​in scripts or automating some aspects of managing their virtual machines

```bash
virsh net-list
```


```bash
virsh net-info default
```

The NAT based network is commonly provided and enabled by default fot the majority of the principal linux distributions that supports  KVM virtualization.

This network configuration uses a Linux brigde combined with Network Address Translation (NAT) to allow that a guest operational system gets output conectivity , independent of the network type (with wire, wireless, dial-up and goes on) used on KVM host with no need of any specific administrator configuration.

## Defining an static IP for our VM

Execute the script define-static-networking-kvm.sh

```bash
./define-static-networking-kvm.sh
```

Put the name of the virtual machine that you want to define the IP, on our case is ubuntu-01

<p align="center"> 
<img src="images/terminal-03.png">
</p>

Copy the line that starts with **<host mac='**

Edit the file of network definition

```bash
sudo virsh net-edit default
```
Add the line that we copied above under **<range**

<p align="center"> 
<img src="images/terminal-04.png">
</p>

Save the file and execute the following commands

```bash
sudo virsh net-destroy default
```

```bash
sudo virsh net-start default
```

```bash
sudo virsh shutdown ubuntu-01
```

```bash
sudo systemctl stop libvirtd && sudo systemctl start libvirtd
```

```bash
sudo virsh start ubuntu-01
```

Test the SSH for our VM

```bash
ssh ubuntu@XXX.XXX.XXX.XXX
```

<p align="center"> 
<img src="images/terminal-05.png">
</p>

# Exposing our VM to external access via IP Tables

Since we are using the configuration of a default network of type NAT we don´t have a network interface addded on our virtual machine, we will use a rule of IP Tables based on a port to accomplish the external access to our virtual server.

We will use the [Hooks of QEMU](https://libvirt.org/hooks.html)

Crieate the following file **/etc/libvirt/hooks/qemu**

```bash
sudo vim /etc/libvirt/hooks/qemu
```

Add the following content

```bash
#!/bin/bash

# Script that add iptables rule to forward traffic to VM's

if [ "${1}" = "VM NAME" ]; then

   # Update the following variables to fit your setup
   GUEST_IP=
   GUEST_PORT=
   HOST_PORT=

   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
	/sbin/iptables -D FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
	/sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
	/sbin/iptables -I FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
	/sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
fi
```

Replacing the following variables for ours, in my case it was like this:

```bash
#!/bin/bash

# Script that add iptables rule to forward traffic to VM's

if [ "${1}" = "ubuntu-01" ]; then

   # Update the following variables to fit your setup
   GUEST_IP=192.168.122.3
   GUEST_PORT=22
   HOST_PORT=2222

   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
	/sbin/iptables -D FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
	/sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
	/sbin/iptables -I FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
	/sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
fi
```

Where GUEST_IP is the IP of our VM, GUEST_PORT is the port that we will do the  redirect of the traffic, in this case SSH port, HOST_PORT the port that we will map from the host to the guest

```bash
sudo chmod +x /etc/libvirt/hooks/qemu
```

```bash
sudo virsh shutdown ubuntu-01
```

```bash
sudo systemctl stop libvirtd && sudo systemctl start libvirtd
```

```bash
sudo virsh start ubuntu-01
```

Testing the SSH, log-off from our EC2 and do the ssh pointing for the port that we will do the forward via IP Tables.

> Obs: Don´t forget to open the Security Group on our EC2 on the port 2222

```bash
ssh ubuntu@EC2_IP -p 2222
```

The result should be the same of loging in from inside the Host OS 

<p align="center"> 
<img src="images/terminal-05.png">
</p>

# References

Networking with KVM
https://aboullaite.me/kvm-qemo-forward-ports-with-iptables/

Setup KVM on Ubuntu 18.04
https://blog.programster.org/set-up-ubuntu-18-04-KVM-server
https://ostechnix.com/setup-headless-virtualization-server-using-kvm-ubuntu/

Helper Script to create VM
https://blog.programster.org/ubuntu-18-04-getting-started-with-kvm-using-php-helper-script

Forwarding connection
https://wiki.libvirt.org/page/Networking#Forwarding_Incoming_Connections

Libvirt Default Networking
https://wiki.libvirt.org/page/Networking