#!/bin/bash
echo "Starting install"

echo 'deb http://download.proxmox.com/debian wheezy pve-no-subscription' > /etc/apt/sources.list.d/proxmox.list
wget -O- 'http://download.proxmox.com/debian/key.asc' | apt-key add -
sed -i 's/^.*::.*$//g' /etc/hosts
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get dist-upgrade -y
rm -rf /boot/vmlinuz*
apt-get install -y pve-firmware pve-kernel-2.6.32-34-pve
apt-get remove -y --force-yes linux-image-*
apt-get install -y proxmox-ve-2.6.32 ntp ssh lvm2 postfix ksm-control-daemon vzprocps bootlogd
apt-get install -y --force-yes iptables-persistent
update-grub
echo 'Completed'
reboot
exit
