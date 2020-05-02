#!/usr/bin/env bash
# ssh to undercloud as root and run this script
# it's probably easier to just copy/paste the contents of 0-site-settings into your terminal, then
# paste in the rest of this script.  This keeps you from having to clone down the entire repo for this simple bit.
source ~/dell-lab/scripts/0-site-settings.sh

# set hostname
hostnamectl set-hostname $hostname.$domain
echo "$ip_address $hostname.$domain" >> /etc/hosts

# register with satellite
dnf localinstall -y "http://$satellite/pub/katello-ca-consumer-latest.noarch.rpm"
subscription-manager register --org $org --activationkey $director_activation_key
dnf clean all

# add stack user
useradd stack
echo $stack_password | passwd stack --stdin
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

# install director installer package
dnf install -y python3-tripleoclient git gcc python3-devel tmux ceph-ansible python3-ovirt-engine-sdk4.x86_64 libguestfs-tools katello-agent

# update all packages and reboot
dnf update -y && reboot


