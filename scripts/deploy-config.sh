#!/usr/bin/env bash
if [ $PWD != $HOME ] ; then echo "USAGE: $0 Must be run from $HOME"; exit 1 ; fi

source ~/dell-lab/scripts/0-site-settings.sh

source ~/stackrc
cd ~
time openstack overcloud deploy --templates \
    --stack $stack_name \
    -p /usr/share/openstack-tripleo-heat-templates/plan-samples/plan-environment-derived-params.yaml \
    -n ~/dell-lab/templates/network_data.yaml \
    -r ~/dell-lab/templates/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/rhsm.yaml \
    -e ~/dell-lab/templates/containers-prepare-parameter.yaml \
    -e ~/dell-lab/templates/environments/storage-config.yaml \
    -e ~/dell-lab/templates/environments/dell-lab-environment.yaml \
    --log-file deployment.log \
    --config-download-only
