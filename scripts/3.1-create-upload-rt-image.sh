#!/usr/bin/env bash
# This script should be run as the stack user on the undercloud

source ~/dell-lab/scripts/0-site-settings.sh
source /home/stack/stackrc

echo "enter cdn password: "
read CDNPASS

cd ~/images
cp -f overcloud-full.qcow2 overcloud-realtime-compute.qcow2

virt-customize -a overcloud-realtime-compute.qcow2 --run-command \
"subscription-manager register --username=$cdn_user --password=$CDNPASS" \
--run-command "subscription-manager attach --pool $pool"

# temporarily include the rpm that we created for the upstream intel i40e for RT

virt-customize -a overcloud-realtime-compute.qcow2 -v \
--copy-in ~/i40e-2.10.19.30-1.x86_64.rpm /root/i40e-2.10.19.30-1.x86_64.rpm \
--run ~/dell-lab/scripts/rt.sh 2>&1 | tee ~/virt-customize.log

virt-customize -a overcloud-realtime-compute.qcow2 --selinux-relabel

#############################
# extract vmliuz and initrd #
#############################
rm -Rf /var/tmp/.guestfs*
mkdir -p ~/images/rt-image
guestmount -a overcloud-realtime-compute.qcow2 -i --ro rt-image
cp rt-image/boot/vmlinuz-*.x86_64 ./overcloud-realtime-compute.vmlinuz
cp rt-image/boot/initramfs-*.x86_64.img ./overcloud-realtime-compute.initrd
guestunmount rt-image
rm -Rf ~/images/rt-image

###########################
# Upload Images to Glance #
###########################
openstack overcloud image upload --image-path /home/stack/images/ \
--update-existing --os-image-name overcloud-realtime-compute.qcow2