#!/bin/bash

# compute.sh

# Authors: Kevin Jackson (kevin@linuxservices.co.uk)
#          Cody Bunch (bunchc@gmail.com)

# Set a proxy if one is accessible on your network?
APT_PROXY="192.168.1.1:3128"
#

# Must define your environment
CONTROLLER_HOST=172.16.0.200
KEYSTONE_ENDPOINT=${CONTROLLER_HOST}
MYSQL_HOST=${CONTROLLER_HOST}
SERVICE_TENANT_NAME=service
SERVICE_PASS=openstack


# If you have a proxy outside of your VirtualBox environment, use it
if [[ ! -z "$APT_PROXY" ]]
then
	echo "Acquire::http::Proxy \"http://${APT_PROXY}\";" | sudo tee /etc/apt/apt.conf
fi


nova_compute_install() {
	export DEBIAN_FRONTEND=noninteractive
	export ENDPOINT=${KEYSTONE_ENDPOINT}
	export SERVICE_TOKEN=ADMIN
	export SERVICE_ENDPOINT=http://${ENDPOINT}:35357/v2.0

	# Setup for Grizzly
	sudo apt-get update
	sudo apt-get install python-software-properties -y
	sudo add-apt-repository ppa:openstack-ubuntu-testing/grizzly-trunk-testing
	sudo add-apt-repository ppa:openstack-ubuntu-testing/grizzly-build-depends
	sudo apt-get update && apt-get upgrade -y

	# Install some packages:
	sudo apt-get -y install nova-api-metadata nova-compute nova-compute-qemu nova-doc nova-network
	sudo service ntp restart
}

nova_configure() {
	# Clobber the nova.conf file with the following
	NOVA_CONF=/etc/nova/nova.conf
	NOVA_API_PASTE=/etc/nova/api-paste.ini
	cat > /tmp/nova.conf << EOF
[DEFAULT]
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf
verbose=True

api_paste_config=/etc/nova/api-paste.ini
enabled_apis=ec2,osapi_compute,metadata

# Libvirt and Virtualization
libvirt_use_virtio_for_bridges=True
connection_type=libvirt
libvirt_type=qemu

# Database
sql_connection=mysql://nova:openstack@${MYSQL_HOST}/nova

# Messaging
rabbit_host=${MYSQL_HOST}

# EC2 API Flags
ec2_host=${MYSQL_HOST}
ec2_dmz_host=${MYSQL_HOST}
ec2_private_dns_show_ip=True

# Networking
public_interface=eth1
force_dhcp_release=True
auto_assign_floating_ip=True

# Images
image_service=nova.image.glance.GlanceImageService
glance_api_servers=${GLANCE_HOST}:9292

# Scheduler
scheduler_default_filters=AllHostsFilter

# Object Storage
iscsi_helper=tgtadm

# Auth
auth_strategy=keystone
keystone_ec2_url=http://${KEYSTONE_ENDPOINT}:5000/v2.0/ec2tokens
EOF

	sudo rm -f $NOVA_CONF
	sudo mv /tmp/nova.conf $NOVA_CONF
	sudo chmod 0640 $NOVA_CONF
	sudo chown nova:nova $NOVA_CONF

	# Paste file
        sudo sed -i "s/127.0.0.1/$KEYSTONE_ENDPOINT/g" $NOVA_API_PASTE
        sudo sed -i "s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT/g" $NOVA_API_PASTE
        sudo sed -i "s/%SERVICE_USER%/nova/g" $NOVA_API_PASTE
        sudo sed -i "s/%SERVICE_PASSWORD%/$SERVICE_PASS/g" $NOVA_API_PASTE

	sudo nova-manage db sync
}

nova_restart() {
	for P in $(ls /etc/init/nova* | cut -d'/' -f4 | cut -d'.' -f1)
	do
		sudo stop ${P}
		sudo start ${P}
	done
}

# Main
nova_compute_install
nova_configure
nova_restart

# Create a private network
sudo nova-manage network create privateNet --fixed_range_v4=10.0.10.0/24 --network_size=64 --bridge_interface=eth2
sudo nova-manage floating create --ip_range=172.16.10.0/24
