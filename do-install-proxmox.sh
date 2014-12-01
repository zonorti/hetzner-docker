#!/bin/bash
echo "Starting install"

echo 'deb http://download.proxmox.com/debian wheezy pve' > /etc/apt/sources.list.d/proxmox.list
wget -O- 'http://download.proxmox.com/debian/key.asc' | apt-key add -
sed -i 's/^.*::.*$//g' /etc/hosts
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get dist-upgrade -y
apt-get install -y pve-firmware pve-kernel-2.6.32-26-pve
apt-get remove -y -f linux-image-amd64 linux-image-$(uname -r) linux-base
apt-get install -y proxmox-ve-2.6.32 ntp ssh lvm2 postfix ksm-control-daemon vzprocps bootlogd
update-grub
echo 'Completed'
reboot
exit
