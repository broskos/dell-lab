#!/usr/bin/env bash
if [ $PWD != $HOME ] ; then echo "USAGE: $0 Must be run from $HOME"; exit 1 ; fi

source ~/dell-lab/scripts/0-site-settings.sh

source ~/stackrc
cd ~
time openstack overcloud deploy --templates \
    --stack $stack_name \
    -n ~/dell-lab/templates/network_data.yaml \
    -r ~/dell-lab/templates/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml \
    -e ~/dell-lab/templates/containers-prepare-parameter.yaml \
    -e ~/dell-lab/templates/environments/dell-lab-environment.yaml \
    --log-file deployment.log

#     -e /usr/share/openstack-tripleo-heat-templates/environments/rhsm.yaml \