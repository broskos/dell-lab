#!/usr/bin/env bash
if [ $PWD != $HOME ] ; then echo "USAGE: $0 Must be run from $HOME"; exit 1 ; fi

source ~/dell-lab/scripts/0-site-settings.sh
export stack_name='central'

source ~/stackrc
cd ~
time openstack overcloud deploy --templates \
    --stack $stack_name \
    -n ~/dell-lab/templates/network_data.yaml \
    -r ~/dell-lab/templates/roles_data_central.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
    -e ~/dell-lab/templates/containers-prepare-parameter.yaml \
    -e ~/dell-lab/templates/environments/storage-config.yaml \
    -e ~/dell-lab/templates/environments/lab-environment-common.yaml \
    -e ~/dell-lab/templates/environments/lab-environment-central.yaml \
    --log-file deployment.log

mkdir -p ~/{dcn-common,central/config-download}
openstack overcloud config download --name central \
  --config-dir ~/central/config-downloadopenstack overcloud config download \
  --name central --config-dir ~/central/config-download

openstack overcloud export \
          --config-download-dir ~/central/config-download/ \
          --stack central \
          --output-file ~/dcn-common/control-plane-export.yaml \
#     -e /usr/share/openstack-tripleo-heat-templates/environments/rhsm.yaml \