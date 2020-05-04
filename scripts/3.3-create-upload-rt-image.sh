#!/usr/bin/env bash
# This script should be run as the stack user on the undercloud

source ~/dell-lab/scripts/0-site-settings.sh
source /home/stack/stackrc

export LIBGUESTFS_BACKEND=direct

# CDN
echo "enter cdn password: "
read CDNPASS

cd ~/images
cp -f overcloud-full.qcow2 overcloud-realtime-compute.qcow2

virt-customize -a overcloud-realtime-compute.qcow2 --run-command \
"subscription-manager register --username=$cdn_user --password=$CDNPASS" \
--run-command "subscription-manager attach --pool $pool"

virt-customize -a overcloud-realtime-compute.qcow2 -v \
--run ~/dell-lab/scripts/rt.sh 2>&1 | tee ~/virt-customize.log

# now that the new kernel is installed we can install the igb_uio driver and config tools
virt-customize -a overcloud-realtime-compute.qcow2 -v \
--run-command "subscription-manager unregister || true" \
--run-command "subscription-manager clean" \
--copy-in ~/dell-lab/config-fpga/config-fpga-2.0-1.el8.x86_64.rpm:/root/ \
--run-command "dnf localinstall -y /root/config-fpga-2.0-1.el8.x86_64.rpm" \
--run-command "chmod +x /etc/rc.d/rc.local" \
--run-command 'cat << EOF >>  /etc/rc.d/rc.local

# manually set smp_affinity
for i in /proc/irq/*/smp_affinity; do
 echo 00000030,00000003 > \$i 2>/dev/null
done

EOF'

virt-sysprep -a overcloud-realtime-compute.qcow2 --selinux-relabel

#############################
# extract vmliuz and initrd #
#############################
sudo rm -Rf /var/tmp/.guestfs*
mkdir -p ~/images/rt-image
guestmount -a overcloud-realtime-compute.qcow2 -i --ro rt-image
cp rt-image/boot/vml*rt* ./overcloud-realtime-compute.vmlinuz
cp rt-image/boot/init*rt* ./overcloud-realtime-compute.initrd
guestunmount rt-image
rm -Rf ~/images/rt-image

###########################
# Upload Images to Glance #
###########################
openstack overcloud image upload --image-path /home/stack/images/ \
--update-existing --os-image-name overcloud-realtime-compute.qcow2