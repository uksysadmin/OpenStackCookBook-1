#!/bin/bash

# common.sh
#
# Authors: Kevin Jackson (kevin@linuxservices.co.uk)
#          Cody Bunch (bunchc@gmail.com)
#
# Sets up common bits used in each build script.
#

export DEBIAN_FRONTEND=noninteractive

export CONTROLLER_HOST=172.16.0.200
export KEYSTONE_ENDPOINT=${CONTROLLER_HOST}
export SERVICE_TENANT_NAME=service
export SERVICE_PASS=openstack
export ENDPOINT=${KEYSTONE_ENDPOINT}
export SERVICE_TOKEN=ADMIN
export SERVICE_ENDPOINT=http://${ENDPOINT}:35357/v2.0

# Setup Proxy
APT_PROXY="172.16.0.110:3128"
#
# If you have a proxy outside of your VirtualBox environment, use it
if [[ ! -z "$APT_PROXY" ]]
then
        echo "Acquire::http::Proxy \"http://${APT_PROXY}\";" | sudo tee /etc/apt/apt.conf
fi

sudo apt-get update
sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:openstack-ubuntu-testing/grizzly-trunk-testing
sudo add-apt-repository ppa:openstack-ubuntu-testing/grizzly-build-depends
sudo apt-get update && apt-get upgrade -y