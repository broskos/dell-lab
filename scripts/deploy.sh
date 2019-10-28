#!/usr/bin/env bash
if [ $PWD != $HOME ] ; then echo "USAGE: $0 Must be run from $HOME"; exit 1 ; fi

source ~/dell-lab/scripts/0-site-settings.sh

source ~/stackrc
cd ~
time openstack overcloud deploy --templates \
    --stack $stack_name \
    -n "${template_path}/network_data.yaml" \
    -r "${template_path}/roles_data.yaml" \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e "${template_path}/environments/overcloud-images.yaml" \
    -e "${template_path}/environments/dell-lab-environment.yaml"

