#!/usr/bin/env bash
# This script should be run as the stack user on the undercloud

source ~/dell-lab/scripts/0-site-settings.sh
source /home/stack/stackrc

cd ~/images
cp -f overcloud-full.qcow2 overcloud-realtime-compute.qcow2
echo "enter cdn password\n"
read CDNPASS
virt-customize -a overcloud-realtime-compute.qcow2 --run-command \
"subscription-manager register broskos@redhat.com --password=$CDNPASS"
virt-customize -a overcloud-realtime-compute.qcow2 --run-command \
"subscription-manager attach --pool $pool"

 virt-customize -a overcloud-realtime-compute.qcow2 -v --selinux-relabel \
 --run ~/dell-lab/scripts/rt.sh 2>&1 | tee ~/virt-customize.log

#############################
# extract vmliuz and initrd #
#############################
guestmount -a overcloud-realtime-compute.qcow2 -i --ro image
cp image/boot/vmlinuz-*.x86_64 ./overcloud-realtime-compute.vmlinuz
cp image/boot/initramfs-*.x86_64.img ./overcloud-realtime-compute.initrd
guestunmount image

###########################
# Upload Images to Glance #
###########################
openstack overcloud image upload --image-path /home/stack/images/ --update-existing