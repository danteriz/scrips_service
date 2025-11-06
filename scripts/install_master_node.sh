#!/bin/bash
set -e

read -p "Укажите имя для worker-ноды: " HOSTNAME_

Echo "Введите адрес и маску сети которая будет использоваться в кластере. Пример: 10.244.0.0/16." 
read -p "Ввод: " NETWORK_KUB


apt update
apt upgrade -y
hostnamectl set-hostname $HOSTNAME_
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
apt install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg 
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet
systemctl start kubelet
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
sysctl --system
ufw allow 6443/tcp
ufw allow 10250/tcp
kubeadm init --pod-network-cidr=$NETWORK_KUB
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

