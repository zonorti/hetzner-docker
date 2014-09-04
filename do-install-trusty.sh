#!/bin/bash
echo "Starting install"
export LANG="C"
export DEBIAN_FRONTEND=noninteractive

TARGET_HOSTNAME=$1
TARGET_DOMAIN=$2
RELEASE="trusty"

REPO="http://de.archive.ubuntu.com/ubuntu/"
DEBOOTSTRAP_VERSION="1.0.59"
TARGET_IPADDR=$(/sbin/ip addr show dev eth0 | awk '/inet /  { print $2 }' | cut -d/ -f 1)
TARGET_NETMASK=$(ifconfig "eth0" | grep 'Mask:' | cut -d: -f4 | awk '{ print $1}')
TARGET_GATEWAY=$(/sbin/ip route | awk '/default/ { print $3 }')
SSH_KEY=$(cat ~/.ssh/authorized_keys)
DISKS=$(cd /dev && ls -1 sd?)
MDS=$(cat /proc/mdstat | egrep '^md' | awk '{print $1}')

function action {
	echo ">>>>> $@ <<<<<"
}

# clear old raid devices
action "clear old RAID devices"
for md in $MDS; do
	PARTITIONS="$PARTITIONS $(mdadm --detail   /dev/md0 | egrep '/dev/sd??' | cut -d/ -f 3)"
	mdadm --remove /dev/$md
	mdadm --stop /dev/$md
done


action "clear RAID lefovers"
for part in $PARTITIONS; do
	mdadm --zero-superblock /dev/$part
done

action "create new partitions"
echo $DISKS
for d in $DISKS; do
	# zap the disk(s)
	sgdisk -Z /dev/$d
	# create BIOS boot partition
	sgdisk -n 3:2048:+1M -t 3:ef02 /dev/$d
	# create md0 partition
	sgdisk -n 1:0:+512M -t 1:fd00 /dev/$d
	# create md1 partition
	sgdisk -n 2:0:+100G -t 2:fd00 /dev/$d
	#create swap
	sgdisk -n 4:0:+16G  -t 4:fd00 /dev/$d
done

# create raid devices
action "create new RAID devices"
yes | mdadm -C /dev/md0 -l 1 -n 2 /dev/sda1 /dev/sdb1
yes | mdadm -C /dev/md1 -l 1 -n 2 /dev/sda2 /dev/sdb2
/usr/share/mdadm/mkconf >/etc/mdadm/mdadm.conf

# create filesystems
action "creating filesystems"
mkfs.ext4 -L boot /dev/md0
mkfs.ext4 -L root /dev/md1
mkswap -f -L swap /dev/sda3
mkswap -f -L swap /dev/sdb3

# mount filesystems stage 1
action "mounting filesystems - stage 1"
swapon -v /dev/sda3
swapon -v /dev/sdb3
mkdir -v /newroot
mount -v /dev/md1 /newroot
mkdir -v /newroot/tmp /newroot/var /newroot/home
mkdir /newroot/boot
mount -v -t ext4 /dev/md0 /newroot/boot

# download and install debootstrap
action "installing debootstrap"
wget ${REPO}pool/main/d/debootstrap/debootstrap_${DEBOOTSTRAP_VERSION}_all.deb
dpkg -i debootstrap_${DEBOOTSTRAP_VERSION}_all.deb
rm debootstrap_*.deb

action "running debootstrap"
debootstrap --arch=amd64 --components=main,restricted,universe,multiverse --verbose $RELEASE /newroot $REPO

action "writing fstab"
cat >/newroot/etc/fstab <<EOF
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
proc            /proc           proc    defaults  0 0
none            /dev/pts        devpts  gid=5,mode=620 0 0
#sys             /sys            sysfs   nodev,noexec,nosuid 0 0
/dev/md1		/               ext4    defaults            0 0
/dev/md0       /boot           ext4    defaults            0 1
/dev/sda3       none            swap    sw                  0 0
/dev/sdb3       none            swap    sw                  0 0
EOF
chroot /newroot /bin/bash -c "grep -v swap /etc/fstab >/etc/mtab"

action "mounting filesystems - stage 2"
mount -v --rbind /dev /newroot/dev
mount -v --rbind /dev/pts /newroot/dev/pts
mount -v --rbind /proc /newroot/proc
mount -v --rbind /sys /newroot/sys
chroot /newroot locale-gen en_US.UTF-8
chroot /newroot update-locale LANG=en_US.UTF-8
#chroot /newroot /bin/bash -c "/usr/share/mdadm/mkconf >/etc/mdadm/mdadm.conf"

echo "Etc/UTC" > /newroot/etc/timezone    
chroot /newroot dpkg-reconfigure -f noninteractive tzdata

action "configure networking"
# TODO
cat >/newroot/etc/network/interfaces <<EOF
# Loopback device:
auto lo
iface lo inet loopback

## device: eth0
auto eth0
iface eth0 inet static
  address ${TARGET_IPADDR}
  netmask ${TARGET_NETMASK}
  gateway ${TARGET_GATEWAY}
EOF

# TODO
cat >/newroot/etc/resolvconf/resolv.conf.d/original <<EOF
search ${TARGET_DOMAIN}
nameserver 127.0.0.1
nameserver 213.133.100.100
nameserver 213.133.99.99
nameserver 213.133.98.98
EOF

# TODO
cat >/newroot/etc/hosts <<EOF
127.0.0.1	localhost
${TARGET_IPADDR} ${TARGET_HOSTNAME}.${TARGET_DOMAIN} ${TARGET_HOSTNAME}

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# TODO
echo "${TARGET_HOSTNAME}" >/newroot/etc/hostname

action "setting up apt"
# install missing packages
cp -f /newroot/etc/apt/sources.list /newroot/etc/apt/sources.list.orig
cat >/newroot/etc/apt/sources.list <<EOF
deb $REPO $RELEASE main restricted universe multiverse 
EOF

action "update package index and install missing packages"
chroot /newroot dpkg --configure -a
chroot /newroot apt-get -yq update
chroot /newroot apt-get -yq install openssh-server lvm2 mdadm initramfs-tools nano htop apparmor
chroot /newroot /bin/bash -c "/usr/share/mdadm/mkconf >/etc/mdadm/mdadm.conf"

action "install kernel and bootloader"
chroot /newroot apt-get -yq install linux-server
chroot /newroot apt-get -yq install grub-pc
chroot /newroot /bin/bash -c "update-initramfs -k all -u"
chroot /newroot /bin/bash -c "grub-install --no-floppy --recheck /dev/sda"
chroot /newroot /bin/bash -c "grub-install --no-floppy --recheck /dev/sdb"
chroot /newroot /bin/bash -c "update-grub"

action "installing authorized_keys"
mkdir -m 0700 /newroot/root/.ssh
# TODO
cat >/newroot/root/.ssh/authorized_keys <<EOF
${SSH_KEY}
EOF

reboot
exit
