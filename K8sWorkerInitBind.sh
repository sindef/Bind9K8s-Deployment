#!/bin/bash

#Check I am a user with root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#Stop it asking to restart things
export DEBIAN_FRONTEND=noninteractive

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


#Run the Jointoken to join the master node
kubeadm join 192.168.11.4:6443 --token <token> \
        --discovery-token-ca-cert-hash sha256: <hash>
