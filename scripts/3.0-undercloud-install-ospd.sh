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
cp ~/dell-lab/stack-home/* ~

if [ ! -f /home/stack/undercloud.conf ] ; then echo "No undercloud.conf" ; exit 1 ; fi


# Install openstack undercloud
cd ~
openstack undercloud install

if [ ! -f /home/stack/stackrc ] ; then  echo "No stackrc, undercloud deploy may have failed" ; exit 2 ; fi
source ~/stackrc

###########################
# Install Director Images #
###########################
sudo yum install -y rhosp-director-images rhosp-director-images-ipa

#############################
# Make Local Copy of Images #
#############################
mkdir -p ~/images
pushd ~/images
for i in /usr/share/rhosp-director-images/overcloud-full-latest-13.0.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-13.0.tar; do
	tar -xvf $i;
done
popd

###########################
# Upload Images to Glance #
###########################
openstack overcloud image upload --image-path /home/stack/images/ --update-existing

