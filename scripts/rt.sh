#!/bin/bash

set -eux

subscription-manager repos \
--enable=rhel-7-server-nfv-rpms \
--enable=rhel-7-server-rpms \
--enable=rhel-7-server-rh-common-rpms \
--enable=rhel-7-server-extras-rpms \
--enable=rhel-7-server-openstack-13-rpms
yum -v -y --setopt=protected_packages= erase kernel.$(uname -m)
yum -v -y install kernel-rt kernel-rt-kvm tuned-profiles-nfv-host
subscription-manager unregister
subscription-manager clean
# temporary - add intel upstream i40e driver
yum localinstall /root/i40e-2.10.19.30-1.x86_64.rpm -y
