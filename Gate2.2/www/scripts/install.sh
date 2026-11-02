#!/bin/sh
#  
# document
# mkdir /mnt/usbflash
# mount /dev/sda1 /mnt/usbflash

cd /
tar -xvf /mnt/usbflash/mbusbacnet/mbusbacnet.tar.gz --no-same-owner
mkdir /mnt/disk/webbox/bacnet/safe
cp /mnt/disk/webbox/scripts/config.xml /mnt/disk/webbox/bacnet/safe/config.xml

cp /mnt/disk/webbox/scripts/bacserv.sh /etc/init.d/bacserv.sh
cp /mnt/disk/webbox/scripts/mini_httpd.sh /etc/init.d/mini_httpd.sh
cp /mnt/disk/webbox/scripts/fstab /etc/fstab
cp /mnt/disk/webbox/scripts/interfaces /etc/network/interfaces
cp /mnt/disk/webbox/scripts/resolv.conf /etc/resolv.conf
cp /mnt/disk/webbox/scripts/hostname /etc/hostname

chmod 777 /etc/init.d/bacserv.sh
chmod 777 /etc/init.d/mini_httpd.sh
update-rc.d mini_httpd.sh defaults 99
update-rc.d bacserv.sh defaults 99
