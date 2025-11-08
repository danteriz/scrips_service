#!/bin/bash
set -e

read -p "Укажите какой порт использовать: " PORT_
read -p "Укажите публичный ключ: " KAY_PUB_

if [ "$USER" = "root" ]; then
    : ${SUDO:=""}
else
    : ${SUDO:="sudo"}
fi
$SUDO touch root/.ssh/authorized_keys
$SUDO echo "$KAY_PUB_" > root/.ssh/authorized_keys
mapfile -t USERS < <(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 && $1 != "root" {print $1}')
for USER_ in "${USERS[@]}"; do
    $SUDO touch /home/$USER_/.ssh/authorized_keys
    $SUDO echo "$KAY_PUB_" > /home/$USER_/.ssh/authorized_keys
done


$SUDO rm -r /etc/ssh/sshd_config.d/*
$SUDO touch /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
$SUDO chmod 755 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
$SUDO tee -a /etc/ssh/sshd_config.d/60-cloudimg-settings.conf << EOF
Port $PORT_
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
UsePAM yes
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server
EOF
$SUDO systemctl stop ssh.socket
$SUDO systemctl disable ssh.socket
$SUDO systemctl restart ssh

echo $KAY_PUB_ > /root/.ssh/