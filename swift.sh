# swift.sh

# Set a proxy?
echo "Acquire::http::Proxy \"http://192.168.1.1:3128\";" | sudo tee /etc/apt/apt.conf


export DEBIAN_FRONTEND=noninteractive
export ENDPOINT=127.0.0.1
export SERVICE_TOKEN=ADMIN
export SERVICE_ENDPOINT=http://${ENDPOINT}:35357/v2.0

# Setup for Grizzly
sudo apt-get update
sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:openstack-ubuntu-testing/grizzly-trunk-testing
sudo add-apt-repository ppa:openstack-ubuntu-testing/grizzly-build-depends
sudo apt-get update && apt-get upgrade -y

# Install some packages:
sudo apt-get install -y swift swift-proxy swift-account swift-container swift-object memcached xfsprogs curl
sudo apt-get -y install ntp
sudo service ntp restart

