#!/bin/bash
set -e

read -p "Укажите публичный ключ: " KAY_PUB_
read -p "Укажите какой порт использовать: " 


if [ "$USER" = "root" ]; then
    : ${SUDO:=""}
    $SUDO cp /root/.ssh/authorized_keys $HOME/.ssh/
else
    : ${SUDO:="sudo"}
    $SUDO cp $HOME/.ssh/authorized_keys /root/.ssh/
fi


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