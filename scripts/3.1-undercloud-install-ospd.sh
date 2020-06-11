#!/usr/bin/env bash
# after reboot
# run as STACK user su - stack

source ~/dell-lab/scripts/0-site-settings.sh

# are we root?  that's bad
if [[ $EUID -eq 0 ]]; then
  echo "Do not run as root; su - stack" 2>&1
  exit 1
fi

# we store files in git that need to be in the
# stack users home directory, fetch them out
cp ~/dell-lab/stack-home/undercloud.conf ~

if [ ! -f /home/stack/undercloud.conf ] ; then echo "No undercloud.conf" ; exit 1 ; fi


# Install openstack undercloud
cd ~
openstack undercloud install

if [ ! -f /home/stack/stackrc ] ; then  echo "No stackrc, undercloud deploy may have failed" ; exit 2 ; fi
source ~/stackrc

###########################
# Install Director Images #
###########################
sudo dnf install -y rhosp-director-images rhosp-director-images-ipa

#############################
# Make Local Copy of Images #
#############################
mkdir -p ~/images
pushd ~/images
for i in /usr/share/rhosp-director-images/overcloud-full-latest-16.0.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-16.0.tar; do
	tar -xvf $i;
done
popd

virt-customize -a ~/images/overcloud-full.qcow2 --root-password password:redhat

###########################
# Upload Images to Glance #
###########################
openstack overcloud image upload --image-path /home/stack/images/ --update-existing

###########################
# Create HCI and edge leaf roles #
###########################
ROLES="compute compute-edge1 compute-edge1vdu compute-edge2 compute-edge2vdu"
for ROLE in $ROLES;do
 openstack flavor create --id auto --ram 4096 --disk 40 --vcpus 1 $ROLE
 openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="$ROLE" --property "resources:CUSTOM_BAREMETAL"="1" --property "resources:DISK_GB"="0" --property "resources:MEMORY_MB"="0" --property "resources:VCPU"="0" $ROLE
done
