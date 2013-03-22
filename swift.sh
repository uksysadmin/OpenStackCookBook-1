# swift.sh

export DEBIAN_FRONTEND=noninteractive
export ENDPOINT=127.0.0.1
export SERVICE_TOKEN=ADMIN
export SERVICE_ENDPOINT=http://${ENDPOINT}:35357/v2.0

# Setup for Grizzly
sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:openstack-ubuntu-testing/grizzly-trunk-testing
sudo add-apt-repository ppa:openstack-ubuntu-testing/grizzly-build-depends
sudo apt-get update

