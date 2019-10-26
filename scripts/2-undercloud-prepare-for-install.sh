#!/usr/bin/env bash
# ssh to undercloud as root and run this script
# it's probably easier to just copy/paste the contents of 0-site-settings into your terminal, then
# paste in the rest of this script.  This keeps you from having to clone down the entire repo for this simple bit.
source ~/dell-lab/scripts/0-site-settings.sh

# set hostname
hostnamectl set-hostname $hostname.$domain
echo "$ip_address $hostname.$domain $hostname" >> /etc/hosts

# register with cdn
echo "enter cdn password\n"
read CDNPASS
subscription-manager register --username=broskos@redhat.com --password=$CDNPASS
subscription-manager attach --pool=$pool
subscription-manager repos --disable "*"
subscription-manager repos \
--enable=rhel-7-server-rpms \
--enable=rhel-7-server-extras-rpms \
--enable=rhel-7-server-rh-common-rpms \
--enable=rhel-ha-for-rhel-7-server-rpms \
--enable=rhel-7-server-openstack-13-rpms \
--enable=rhel-7-server-rhceph-3-tools-rpms
yum clean all


# add stack user
useradd stack
echo $stack_password | passwd stack --stdin
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

# install director installer package
yum install -y python-tripleoclient git gcc python-devel screen ceph-ansible python-ovirt-engine-sdk4.x86_64 libguestfs-tools

# update all packages and reboot
yum -y update && reboot

