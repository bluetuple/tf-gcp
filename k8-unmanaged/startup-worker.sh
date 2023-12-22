#! /bin/bash

#kernel modules
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# k8 networking requirements
cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward =1
net.bridge.bridge-nf-call-iptables = 1
EOF


sudo sysctl --system

# install containderd
sudo apt-get update && sudo apt-get install -y containerd

# containerd configuration
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# restart continerd to use generated config
sudo systemctl restart containerd

# disable swapoff as a requirement for k8
sudo swapoff -a
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

# add apt-get key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# add kubernetes packages
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update && sudo apt-get install -y kubelet=1.27.0-00 kubeadm=1.27.0-00 kubectl=1.27.0-00

# do not automatically update to keep version
sudo apt-mark hold kubelet kubeadm kubectl










