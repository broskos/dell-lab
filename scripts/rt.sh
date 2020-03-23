#!/bin/bash

set -eux

subscription-manager repos --disable '*'
subscription-manager repos \
--enable=rhel-8-for-x86_64-baseos-rpms \
--enable=rhel-8-for-x86_64-appstream-rpms \
--enable=rhel-8-for-x86_64-highavailability-rpms \
--enable=ansible-2.8-for-rhel-8-x86_64-rpms \
--enable=openstack-16-for-rhel-8-x86_64-rpms \
--enable=rhel-8-for-x86_64-nfv-rpms \
--enable=advanced-virt-for-rhel-8-x86_64-rpms \
--enable=fast-datapath-for-rhel-8-x86_64-rpms
dnf -v -y --disableplugin=protected_packages remove kernel.$(uname -m)
dnf -v -y install kernel-rt kernel-rt-kvm kernel-rt-devel tuned-profiles-nfv-host kernel-devel gcc
subscription-manager unregister
subscription-manager clean


