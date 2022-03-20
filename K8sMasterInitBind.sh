#!/bin/bash

ipaddr=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')

#Check I am a user with root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#Update and install Docker-Compose (this will give us all the dependencies we need)
apt-get update && apt-get install -y docker-compose

#Add the Kubernetes repo
apt-get install -y apt-transport-https && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

#Grab Kubernetes and update the apt-get package index
#For a master node, install Kubectl as well
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main"  | tee -a /etc/apt/sources.list.d/kubernetes.list && sudo apt-get update
apt-get install -yq kubelet kubeadm kubernetes-cni

#Disable swap if on - however the nodes should be deployed with no swap, and if it does exist it should be unmounted and removed. The below will only temporarily disable swap.
swapoff -a

#Init the master node - advertise on the network
kubeadm init --apiserver-advertise-address=$ipaddr

#Remember to create environment variables as below for a regular user:
#   mkdir -p $HOME/.kube
#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#   sudo chown $(id -u):$(id -g) $HOME/.kube/config


echo "Kubernetes is now installed and ready to be used"

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml - This will install the flannel network
#On my master node, the flannel network did not init correctly - so I manually created /run/flannel/subnet.env and added the following:
# FLANNEL_NETWORK=10.244.0.0/16
# FLANNEL_SUBNET=10.244.0.1/24
# FLANNEL_MTU=1450
# FLANNEL_IPMASQ=true
#May not be required if you use Host Networking or another method of networking
