#!/bin/bash

# common.sh
#
# Authors: Kevin Jackson (kevin@linuxservices.co.uk)
#          Cody Bunch (bunchc@gmail.com)
#
# Sets up common bits used in each build script.
#

KEYSTONE_ENDPOINT=172.16.0.200
SERVICE_TENANT_NAME=service
SERVICE_PASS=openstack

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