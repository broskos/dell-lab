#!/usr/bin/env bash

# This script should be run as the stack user on the undercloud

# instackenv.yaml should contain all hosts in the deployment.
# In the OpenStack documentation, this file is called instackenv.json

# [ -f /home/stack/instackenv.yaml ] || echo "instackenv.yaml not found" && exit 1
source /home/stack/stackrc

#######################
# Import Ironic Nodes #
#######################
openstack overcloud node import ~/dell-lab/stack-home/instackenv.yaml

openstack overcloud node introspect --all-manageable --provide

