# compute.sh

# Set a proxy?
echo "Acquire::http::Proxy \"http://192.168.1.1:3128\";" | sudo tee /etc/apt/apt.conf

KEYSTONE_ENDPOINT=172.16.172.200
SERVICE_TENANT_NAME=service
SERVICE_PASS=openstack

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
	sudo apt-get -y install nova-api-metadata nova-compute nova-compute-qemu nova-doc
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
sql_connection=mysql://nova:openstack@172.16.172.200/nova

# Messaging
rabbit_host=172.16.172.200

# EC2 API Flags
ec2_host=172.16.172.200
ec2_dmz_host=172.16.172.200
ec2_private_dns_show_ip=True

# Networking
public_interface=eth1
force_dhcp_release=True

# Images
image_service=nova.image.glance.GlanceImageService
glance_api_servers=172.16.172.200:9292

# Scheduler
scheduler_default_filters=AllHostsFilter

# Object Storage
iscsi_helper=tgtadm
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
#sudo nova-manage network create privateNet --fixed_range_v4=10.0.0.0/24 --network_size=64 --bridge_interface=eth2
