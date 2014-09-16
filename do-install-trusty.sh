#!/bin/bash
echo "Starting install"

TARGET_HOSTNAME=$1
TARGET_DOMAIN=$2


/sbin/wipefs -a /dev/sda
/sbin/wipefs -a /dev/sdb
export TERM=xterm

# Workarond for installimage using dialog for warnings
# Dialog sucks at autoistalls
rm /usr/bin/dialog
ln -s /bin/echo /usr/bin/dialog

cat >/autosetup <<EOF

DRIVE1 /dev/sda
DRIVE2 /dev/sdb
FORMATDRIVE2 0
SWRAID 0
SWRAIDLEVEL 1
BOOTLOADER grub
HOSTNAME ${TARGET_HOSTNAME}.${TARGET_DOMAIN}
PART swap swap 48G
PART /boot ext3 512M
PART /    btrfs all
IMAGE /root/images/Ubuntu-1404-trusty-64-minimal.tar.gz
EOF

/root/.oldroot/nfs/install/installimage -a -c /autosetup

reboot
exit
