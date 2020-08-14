#!/bin/bash

set -eux

dnf -v -y --setopt=protected_packages= erase kernel.$(uname -m)
dnf -v -y install kernel-rt kernel-rt-kvm tuned-profiles-nfv-host kernel-rt-devel \
kernel-devel gcc make elfutils-libelf-devel libuuid-devel intel-cmt-cat config-fpga
echo "isolate_managed_irq=Y" >> /etc/tuned/realtime-virtual-host-variables.conf



