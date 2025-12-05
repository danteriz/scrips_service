#!/bin/bash
set -e

read -p "Укажите имя для worker-ноды: " HOSTNAME_
echo "Выполните команду на master-ноде:  kubeadm token create --print-join-command"
read -p "Введите команду с master-ноды для присоединения worker-ноды: " TOKEN_KUB

if [ "$USER" = "root" ]; then
    : ${SUDO:=""}
else
    : ${SUDO:="sudo"}
fi


$SUDO systemctl stop kubelet || true
$SUDO systemctl stop containerd || true
$SUDO kubeadm reset -f || true
$SUDO rm -rf /etc/kubernetes
$SUDO rm -rf /var/lib/kubelet
$SUDO rm -rf /var/lib/etcd
$SUDO rm -rf /etc/cni
$SUDO fuser -k 10250/tcp || true



$SUDO apt update
$SUDO apt upgrade -y
$SUDO hostnamectl set-hostname $HOSTNAME_
$SUDO swapoff -a
$SUDO sed -i '/ swap / s/^/#/' /etc/fstab
$SUDO apt install -y apt-transport-https ca-certificates curl gnupg lsb-release conntrack socat ebtables ethtool ipset ipvsadm containerd
$SUDO mkdir -p /etc/containerd
$SUDO containerd config default | $SUDO tee /etc/containerd/config.toml >/dev/null
$SUDO sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
$SUDO systemctl restart containerd
$SUDO systemctl enable containerd
$SUDO mkdir -p /etc/apt/keyrings
$SUDO curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | $SUDO gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg 
$SUDO echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | $SUDO tee /etc/apt/sources.list.d/kubernetes.list
$SUDO apt update
$SUDO apt install -y kubelet kubeadm kubectl
$SUDO apt-mark hold kubelet kubeadm kubectl
$SUDO systemctl enable kubelet
$SUDO systemctl start kubelet
$SUDO echo "net.ipv4.ip_forward=1" | $SUDO tee /etc/sysctl.d/99-kubernetes-cri.conf
$SUDO sysctl --system
$SUDO ufw allow 6443/tcp
$SUDO ufw allow 10250/tcp
$SUDO systemctl daemon-reload
$SUDO systemctl enable kubelet
$SUDO systemctl start kubelet
$SUDO $TOKEN_KUB
$SUDO reboot -f
