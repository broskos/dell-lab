source ~/dell-lab/scripts/0-site-settings.sh
source ~/centralrc
stack_name="central"

####################################
# fix stackrc for non standard stack name
####################################
if ! grep -Fq "TRIPLEO_PLAN_NAME" ~/stackrc
then
  echo "export TRIPLEO_PLAN_NAME=$stack_name" >> ~/stackrc
fi

#################################
# Upload RHEL Images to Glance
#################################
openstack image create --public --file ~/images/rhel-server-7.7-x86_64-kvm.qcow2 --disk-format qcow2 --container bare rhel-77
openstack image create --public --file ~/images/rhel-8.1-x86_64-kvm.qcow2 --disk-format qcow2 --container bare rhel-81
openstack image create --public --file ~/images/rhel-8.2-x86_64-kvm.qcow2 --disk-format qcow2 --container bare rhel-82

##########################
# Create Default Flavors #
##########################
openstack flavor create --ram 2048 --disk 10 --vcpus 1 m1.small

openstack flavor create --ram 2048 --disk 10 --vcpus 1 \
--property hw:cpu_policy='dedicated' \
--property hw:mem_page_size='1GB' \
--property hw:pci_numa_affinity_policy='required' \
--property hw:emulator_threads_policy='share' \
m1.small-dedicated

openstack flavor create --ram 24576 --disk 20 --vcpus 18 \
--property hw:cpu_l3_cachelines='4' \
--property hw:cpu_policy='dedicated' \
--property hw:mem_page_size='1GB' \
--property hw:pci_numa_affinity_policy='required' \
--property hw:cpu_thread_policy='require' \
--property hw:numa_mempolicy='strict' \
--property hw:emulator_threads_policy='share' \
--property hw:cpu_realtime='yes' \
--property hw:cpu_realtime_mask='^0-1' \
--property hw:pmu='false' \
--property pci_passthrough:alias='vc_fpga:1' \
vdu-test-dedicated

#############################
# Create Networks without routed provider network#
#############################
openstack network create --provider-physical-network ovs-provider --provider-network-type vlan --provider-segment 117 management-central-net
openstack subnet create --network management-central-net --no-dhcp --subnet-range 172.17.117.0/26 --gateway 172.17.117.62 --dns-nameserver 172.17.118.6 management-central-subnet
openstack network create --provider-physical-network ovs-provider-edge1 --provider-network-type vlan --provider-segment 1117 management-edge1-net
openstack subnet create --network management-edge1-net --no-dhcp --subnet-range 172.17.117.64/26 --gateway 172.17.117.126 --dns-nameserver 172.17.118.6 management-edge1-subnet
openstack network create --provider-physical-network ovs-provider-edge2 --provider-network-type vlan --provider-segment 2117 management-edge2-net
openstack subnet create --network management-edge2-net --no-dhcp --subnet-range 172.17.117.128/26 --gateway 172.17.117.190 --dns-nameserver 172.17.118.6 management-edge2-subnet

openstack network create --provider-physical-network sriov1 --provider-network-type vlan --provider-segment 202 backhaul1-central-net
openstack subnet create --network backhaul1-central-net --no-dhcp --subnet-range 192.168.202.0/26 --gateway 192.168.202.62 \
--allocation-pool start=192.168.202.1,end=192.168.202.30 \
--host-route destination=192.168.202.64/26,gateway=192.168.202.62 --host-route destination=192.168.202.128/26,gateway=192.168.202.62 backhaul1-central-subnet
openstack network create --provider-physical-network sriov1-edge1 --provider-network-type vlan --provider-segment 1202 backhaul1-edge1-net
openstack subnet create --network backhaul1-edge1-net --no-dhcp --subnet-range 192.168.202.64/26 --gateway 192.168.202.126 \
--allocation-pool start=192.168.202.65,end=192.168.202.94 \
--host-route destination=192.168.202.0/26,gateway=192.168.202.126 --host-route destination=192.168.202.128/26,gateway=192.168.202.126 backhaul1-edge1-subnet
openstack network create --provider-physical-network sriov1-edge2 --provider-network-type vlan --provider-segment 2202 backhaul1-edge2-net
openstack subnet create --network backhaul1-edge2-net --no-dhcp --subnet-range 192.168.202.128/26 --gateway 192.168.202.190 \
--allocation-pool start=192.168.202.129,end=192.168.202.158 \
--host-route destination=192.168.202.0/26,gateway=192.168.202.190 --host-route destination=192.168.202.64/26,gateway=192.168.202.190 backhaul1-edge2-subnet
openstack network create --provider-physical-network sriov2 --provider-network-type vlan --provider-segment 202 backhaul2-central-net
openstack subnet create --network backhaul2-central-net --no-dhcp --subnet-range 192.168.202.0/26 --gateway 192.168.202.62 \
--allocation-pool start=192.168.202.31,end=192.168.202.60 \
--host-route destination=192.168.202.64/26,gateway=192.168.202.62 --host-route destination=192.168.202.128/26,gateway=192.168.202.62 backhaul2-central-subnet
openstack network create --provider-physical-network sriov2-edge1 --provider-network-type vlan --provider-segment 1202 backhaul2-edge1-net
openstack subnet create --network backhaul2-edge1-net --no-dhcp --subnet-range 192.168.202.64/26 --gateway 192.168.202.126 \
--allocation-pool start=192.168.202.95,end=192.168.202.124 \
--host-route destination=192.168.202.0/26,gateway=192.168.202.126 --host-route destination=192.168.202.128/26,gateway=192.168.202.126 backhaul2-edge1-subnet
openstack network create --provider-physical-network sriov2-edge2 --provider-network-type vlan --provider-segment 2202 backhaul2-edge2-net
openstack subnet create --network backhaul2-edge2-net --no-dhcp --subnet-range 192.168.202.128/26 --gateway 192.168.202.190 \
--allocation-pool start=192.168.202.159,end=192.168.202.188 \
--host-route destination=192.168.202.0/26,gateway=192.168.202.190 --host-route destination=192.168.202.64/26,gateway=192.168.202.190 backhaul2-edge2-subnet

openstack network create --provider-physical-network sriov1 --provider-network-type vlan --provider-segment 205 midhaul1-central-net
openstack subnet create --network midhaul1-central-net --no-dhcp --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 \
--allocation-pool start=192.168.205.1,end=192.168.205.30 \
--host-route destination=192.168.205.64/26,gateway=192.168.205.62 --host-route destination=192.168.205.128/26,gateway=192.168.205.62 midhaul1-central-subnet
openstack network create --provider-physical-network sriov1-edge1 --provider-network-type vlan --provider-segment 1205 midhaul1-edge1-net
openstack subnet create --network midhaul1-edge1-net --no-dhcp --subnet-range 192.168.205.64/26 --gateway 192.168.205.126 \
--allocation-pool start=192.168.205.65,end=192.168.205.94 \
--host-route destination=192.168.205.0/26,gateway=192.168.205.126 --host-route destination=192.168.205.128/26,gateway=192.168.205.126 midhaul1-edge1-subnet
openstack network create --provider-physical-network sriov1-edge2 --provider-network-type vlan --provider-segment 2205 midhaul1-edge2-net
openstack subnet create --network midhaul1-edge2-net --no-dhcp --subnet-range 192.168.205.128/26 --gateway 192.168.205.190 \
--allocation-pool start=192.168.205.129,end=192.168.205.158 \
--host-route destination=192.168.205.0/26,gateway=192.168.205.190 --host-route destination=192.168.205.64/26,gateway=192.168.205.190 midhaul1-edge2-subnet
openstack network create --provider-physical-network sriov2 --provider-network-type vlan --provider-segment 205 midhaul2-central-net
openstack subnet create --network midhaul2-central-net --no-dhcp --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 \
--allocation-pool start=192.168.205.31,end=192.168.205.60 \
--host-route destination=192.168.205.64/26,gateway=192.168.205.62 --host-route destination=192.168.205.128/26,gateway=192.168.205.62 midhaul2-central-subnet
openstack network create --provider-physical-network sriov2-edge1 --provider-network-type vlan --provider-segment 1205 midhaul2-edge1-net
openstack subnet create --network midhaul2-edge1-net --no-dhcp --subnet-range 192.168.205.64/26 --gateway 192.168.205.126 \
--allocation-pool start=192.168.205.95,end=192.168.205.124 \
--host-route destination=192.168.205.0/26,gateway=192.168.205.126 --host-route destination=192.168.205.128/26,gateway=192.168.205.126 midhaul2-edge1-subnet
openstack network create --provider-physical-network sriov2-edge2 --provider-network-type vlan --provider-segment 2205 midhaul2-edge2-net
openstack subnet create --network midhaul2-edge2-net --no-dhcp --subnet-range 192.168.205.128/26 --gateway 192.168.205.190 \
--allocation-pool start=192.168.205.159,end=192.168.205.188 \
--host-route destination=192.168.205.0/26,gateway=192.168.205.190 --host-route destination=192.168.205.64/26,gateway=192.168.205.190 midhaul2-edge2-subnet

openstack network create --provider-physical-network fronthaul1-edge1 --provider-network-type vlan --provider-segment 1203 fronthaul1-edge1-net
openstack subnet create --network fronthaul1-edge1-net --no-dhcp --subnet-range 192.168.203.64/26 --gateway 192.168.203.126 \
--allocation-pool start=192.168.203.65,end=192.168.203.94 \
--host-route destination=192.168.203.0/26,gateway=192.168.203.126 --host-route destination=192.168.203.128/26,gateway=192.168.203.126 fronthaul1-edge1-subnet
openstack network create --provider-physical-network fronthaul1-edge2 --provider-network-type vlan --provider-segment 2203 fronthaul1-edge2-net
openstack subnet create --network fronthaul1-edge2-net --no-dhcp --subnet-range 192.168.203.128/26 --gateway 192.168.203.190 \
--allocation-pool start=192.168.203.129,end=192.168.203.158 \
--host-route destination=192.168.203.0/26,gateway=192.168.203.190 --host-route destination=192.168.203.64/26,gateway=192.168.203.190 fronthaul1-edge2-subnet
openstack network create --provider-physical-network fronthaul2-edge1 --provider-network-type vlan --provider-segment 1203 fronthaul2-edge1-net
openstack subnet create --network fronthaul2-edge1-net --no-dhcp --subnet-range 192.168.203.64/26 --gateway 192.168.203.126 \
--allocation-pool start=192.168.203.95,end=192.168.203.124 \
--host-route destination=192.168.203.0/26,gateway=192.168.203.126 --host-route destination=192.168.203.128/26,gateway=192.168.203.126 fronthaul2-edge1-subnet
openstack network create --provider-physical-network fronthaul2-edge2 --provider-network-type vlan --provider-segment 2203 fronthaul2-edge2-net
openstack subnet create --network fronthaul2-edge2-net --no-dhcp --subnet-range 192.168.203.128/26 --gateway 192.168.203.190 \
--allocation-pool start=192.168.203.159,end=192.168.203.188 \
--host-route destination=192.168.203.0/26,gateway=192.168.203.190 --host-route destination=192.168.203.64/26,gateway=192.168.203.190 fronthaul2-edge2-subnet

openstack network create --provider-physical-network sriov1-edge1 --provider-network-type vlan --provider-segment 1204 ar1-edge1-net
openstack subnet create --network ar1-edge1-net --no-dhcp --subnet-range 192.168.204.64/26 --gateway 192.168.204.126 \
--allocation-pool start=192.168.204.65,end=192.168.204.94 \
--host-route destination=192.168.204.0/26,gateway=192.168.204.126 --host-route destination=192.168.204.128/26,gateway=192.168.204.126 ar1-edge1-subnet
openstack network create --provider-physical-network sriov1-edge2 --provider-network-type vlan --provider-segment 2204 ar1-edge2-net
openstack subnet create --network ar1-edge2-net --no-dhcp --subnet-range 192.168.204.128/26 --gateway 192.168.204.190 \
--allocation-pool start=192.168.204.129,end=192.168.204.158 \
--host-route destination=192.168.204.0/26,gateway=192.168.204.190 --host-route destination=192.168.204.64/26,gateway=192.168.204.190 ar1-edge2-subnet
openstack network create --provider-physical-network sriov2-edge1 --provider-network-type vlan --provider-segment 1204 ar2-edge1-net
openstack subnet create --network ar2-edge1-net --no-dhcp --subnet-range 192.168.204.64/26 --gateway 192.168.204.126 \
--allocation-pool start=192.168.204.95,end=192.168.204.124 \
--host-route destination=192.168.204.0/26,gateway=192.168.204.126 --host-route destination=192.168.204.128/26,gateway=192.168.204.126 ar2-edge1-subnet
openstack network create --provider-physical-network sriov2-edge2 --provider-network-type vlan --provider-segment 2204 ar2-edge2-net
openstack subnet create --network ar2-edge2-net --no-dhcp --subnet-range 192.168.204.128/26 --gateway 192.168.204.190 \
--allocation-pool start=192.168.204.159,end=192.168.204.188 \
--host-route destination=192.168.204.0/26,gateway=192.168.204.190 --host-route destination=192.168.204.64/26,gateway=192.168.204.190 ar2-edge2-subnet

# increase quotas for admin project
openstack quota set --cores 200 --instances 200 --ram 500000 --volumes 200 --secgroups 100 --gigabytes 3072 --server-group-members 20 --server-groups 20 admin
openstack keypair create  --public-key ~/.ssh/id_rsa.pub undercloud-key

# fixup Availability zones
openstack aggregate create --zone edge1vdu edge1vdu || true
openstack aggregate create --zone edge2vdu edge2vdu || true
openstack aggregate remove host edge1 edge1-computevdu-0.lab.local || true
openstack aggregate remove host edge2 edge2-computevdu-0.lab.local || true
openstack aggregate add host edge1vdu edge1-computevdu-0.lab.local || true
openstack aggregate add host edge2vdu edge2-computevdu-0.lab.local || true

# create user-data file
cat << EOF > ~/admin-user-data.txt
#cloud-config
# vim:syntax=yaml
debug: True
ssh_pwauth: True
disable_root: false
chpasswd:
  list: |
    root:redhat
    cloud-user:redhat
  expire: false
runcmd:
- sed -i'.orig' -e's/without-password/yes/' /etc/ssh/sshd_config
- service sshd restart
EOF

# get security group id for default security group in admin project
group=$(openstack security group list --project admin -f value -c ID)
openstack security group rule create $group  \
  --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0
openstack security group rule create $group \
  --protocol icmp --remote-ip 0.0.0.0/0

exit 0
====== setup some really basic test VMs

openstack server create --flavor m1.small \
--image rhel-77 \
--network management-net \
--network backhaul1-net \
--network midhaul1-net \
--min 5 --max 5 \
--config-drive True \
--availability-zone nova \
--key-name undercloud-key \
--user-data ~/admin-user-data.txt \
test-central

openstack server create --flavor m1.small \
--image rhel-77 \
--network management-net \
--min 2 --max 2 \
--config-drive True \
--availability-zone edge1 \
--key-name undercloud-key \
test-edge1

openstack server create --flavor m1.small \
--image rhel-77 \
--network management-net \
--min 2 --max 2 \
--config-drive True \
--availability-zone edge2 \
--key-name undercloud-key \
test-edge2

exit 0

#======================= Create Testing server for each network  ================================================

# Create central VMs 1 net per VM
for EDGE in central; do
for NETWORK in backhaul1 midhaul1 backhaul2 midhaul2 management; do
openstack server group show $NETWORK -f value -c id
if [[ $? -ne 0 ]]
then
  openstack server group create --policy soft-anti-affinity --os-compute-api 2.15 $NETWORK
fi
for COUNT in {1..5}; do

if [[ $NETWORK = "management" ]]
then
  VNIC=''
else
  VNIC='--vnic-type direct'
fi

PORT=$(openstack port create --network $NETWORK-$EDGE-net $VNIC -f value -c id test-$NETWORK-$EDGE-$COUNT)
GROUP=$(openstack server group show $NETWORK -f value -c id)

openstack server create --flavor m1.small-dedicated \
--image rhel-77 \
--port $PORT \
--config-drive True \
--availability-zone $EDGE \
--key-name undercloud-key \
--user-data ~/admin-user-data.txt \
--hint group=$GROUP \
test-$EDGE-$NETWORK-$COUNT

done
done
done

# Create edge1/2 VMs 1 net per VM
for EDGE in edge1; do
for SERVER in vcu vdu; do
for COUNT in {1..2}; do
if [[ $SERVER = "vcu" ]]
then
  AZ=$EDGE
  NETWORKS='backhaul1 backhaul2 midhaul1 midhaul2 management'
else
  AZ="${EDGE}vdu"
  NETWORKS='fronthaul1 fronthaul2 midhaul1 midhaul2 ar1 ar2 management'
fi

for NETWORK in $NETWORKS; do
openstack server group show $NETWORK -f value -c id
if [[ $? -ne 0 ]]
then
  openstack server group create --policy soft-anti-affinity --os-compute-api 2.15 $NETWORK
fi
if [[ $NETWORK = "management" ]]
then
  VNIC=''
else
  VNIC='--vnic-type direct'
fi

PORT=$(openstack port create --network $NETWORK-$EDGE-net $VNIC -f value -c id test-$SERVER-$NETWORK-$EDGE-$COUNT)
GROUP=$(openstack server group show $NETWORK -f value -c id)

openstack server create --flavor m1.small-dedicated \
--image rhel-77 \
--port $PORT \
--config-drive True \
--availability-zone $AZ \
--key-name undercloud-key \
--user-data ~/admin-user-data.txt \
--hint group=$GROUP \
test-$EDGE-$SERVER-$NETWORK-$COUNT

done
done
done
done


exit 0
#--------------- cleanup scripts USE WITH CAUTION, deletes all servers and ports for current tenant ---------------------------

# Delete all VMs and Ports
for VM in $( openstack server list -f value -c ID );do
openstack server delete $VM
done

for PORT in $( openstack port list -f value -c ID );do
openstack port delete $PORT
done

# or delete specific VMs and Ports

for EDGE in edge2; do
for SERVER in vdu; do
for COUNT in {1..2}; do
if [[ $SERVER = "vcu" ]]
then
  AZ=$EDGE
  NETWORKS='backhaul1 backhaul2 midhaul1 midhaul2 management'
else
  AZ="${EDGE}vdu"
  NETWORKS='fronthaul1 fronthaul2 midhaul1 midhaul2 ar1 ar2 management'
fi
for NETWORK in $NETWORKS; do
openstack server delete "test-$EDGE-$SERVER-$NETWORK-$COUNT" || true
openstack port delete "test-$SERVER-$NETWORK-$EDGE-$COUNT" || true

done
done
done
done

# launch 4 test VDU VMs for Cyclictest
EDGE=edge2
NETWORK1=management
NETWORK2=fronthaul1
NETWORK3=ar1
NETWORK4=midhaul1
for COUNT in {1..4}; do
PORT1=$(openstack port create --tag cyclictest --network $NETWORK1-$EDGE-net -f value -c id cyclictest-vdu-$NETWORK1-$EDGE-$COUNT)
#PORT2=$(openstack port create --tag cyclictest --network $NETWORK2-$EDGE-net -f value -c id cyclictest-vdu-$NETWORK2-$EDGE-$COUNT)
#PORT3=$(openstack port create --tag cyclictest --network $NETWORK3-$EDGE-net -f value -c id cyclictest-vdu-$NETWORK3-$EDGE-$COUNT)
#PORT4=$(openstack port create --tag cyclictest --network $NETWORK4-$EDGE-net -f value -c id cyclictest-vdu-$NETWORK4-$EDGE-$COUNT)
openstack server create --flavor vdu-test-dedicated \
--image vdu-test-image \
--port $PORT1 \
--config-drive True \
--availability-zone edge2vdu \
--key-name undercloud-key \
--user-data ~/admin-user-data.txt \
cyclictest-$EDGE-$NETWORK1-$COUNT
done


#remove edge nodes from aggregates
for AZ in edge1 edge2 ; do
      openstack aggregate remove host "$AZvdu" "$AZ-computevdu-0.lab.local"
      openstack aggregate remove host "$AZ" "$AZ-compute-0.lab.local"
done

# ping test for all vms
for IP in $(openstack server list --status ACTIVE -f value -c Networks | sed 's/^[^=]*=//g'); do
ping -c1 $IP> /dev/null && echo "Ping $IP Connected" || echo "Ping $IP Failed"
done
