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

# now we have to map the neutron ports individual servers to their leaf
for NODE in controller1 controller2 controller3 compute1 compute2 compute3; do
PORT=$(openstack baremetal port list --node $NODE -f value -c UUID)
openstack baremetal port set --physical-network leaf0 $PORT
done

for NODE in edge1vdu-1 edge1-1; do
PORT=$(openstack baremetal port list --node $NODE -f value -c UUID)
openstack baremetal port set --physical-network edge1 $PORT
done

for NODE in edge2vdu-1 edge2-1; do
PORT=$(openstack baremetal port list --node $NODE -f value -c UUID)
openstack baremetal port set --physical-network edge2 $PORT
done

# Introspect, clean and set to available
openstack overcloud node introspect --all-manageable --provide

