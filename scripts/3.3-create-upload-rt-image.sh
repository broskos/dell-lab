#!/usr/bin/env bash
# This script should be run as the stack user on the undercloud

source ~/dell-lab/scripts/0-site-settings.sh
source /home/stack/stackrc

export LIBGUESTFS_BACKEND=direct


cd ~/images
cp -f overcloud-full.qcow2 overcloud-realtime-compute.qcow2

virt-customize -a overcloud-realtime-compute.qcow2 -v \
--run-command "dnf localinstall -y http://$satellite/pub/katello-ca-consumer-latest.noarch.rpm" \
--run-command "/usr/bin/hostname realtime-image.vran.lab; export HOSTNAME=realtime-image.vran.lab; \
  subscription-manager register --name realtime-image.vran.lab --org $org --activationkey $realtime_activation_key"

virt-customize -a overcloud-realtime-compute.qcow2 -v \
--run ~/dell-lab/scripts/rt.sh 2>&1 | tee ~/virt-customize.log

virt-customize -a overcloud-realtime-compute.qcow2 -v \
--run-command "subscription-manager unregister || true" \
--run-command "subscription-manager clean" \
--run-command "systemctl disable irqbalance.service" \
--run-command "chmod +x /etc/rc.d/rc.local" \
--run-command 'cat << EOF >>  /etc/rc.d/rc.local

# setup CAT
pqos -e "llc:0=0x700;llc:1=0xff" -a "llc:0=0,1,40,41;llc:1=2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79"

# loop to set smp_affinity at boot time
for i in /proc/irq/*/smp_affinity; do
 echo 00000300,00000003 > \$i 2>/dev/null
done

EOF'

# Work around naming collisions issue bz-1858417 putting it in the image so that it runs on firstboot
# which avoids issues with provisioning nic getting named before tripleo kernel cmdline is written
virt-customize -a overcloud-realtime-compute.qcow2 \
    --edit '/etc/default/grub:
      s/^GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="biosdevname=1 /' \
    --run-command 'grub2-mkconfig -o /boot/grub2/grub.cfg'

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
