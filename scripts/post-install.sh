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
# Upload RHEL 7 Image to Glance
#################################
openstack image create --public --file ~/images/rhel-server-7.7-x86_64-kvm.qcow2 --disk-format qcow2 --container bare rhel-77

##########################
# Create Default Flavors #
##########################
openstack flavor create --ram 2048 --disk 20 --vcpus 1 m1.small
openstack flavor create --ram 2048 --disk 20 --vcpus 1 --property hw:cpu_policy=dedicated --property hw:mem_page_size=1GB m1.small-dedicated

#############################
# Create Management Network as routed provider network#
#############################
openstack network create --provider-physical-network management --provider-network-type vlan --provider-segment 117 management-net
uuid=$(openstack network segment list --network management-net -f value -c ID)
openstack network segment set --name mgmt-central $uuid
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-central --subnet-range 172.17.117.0/26 --gateway 172.17.117.62 --dns-nameserver 172.17.118.8 management-subnet
openstack network segment create --network management-net --physical-network mgmt-edge1 --network-type vlan --segment 1117  mgmt-edge1
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-edge1 --subnet-range 172.17.117.64/26 --gateway 172.17.117.126 --dns-nameserver 172.17.118.8 mgmt-edge1-subnet
openstack network segment create --network management-net --physical-network mgmt-edge2 --network-type vlan --segment 2117 mgmt-edge2
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-edge2 --subnet-range 172.17.117.128/26 --gateway 172.17.117.190 --dns-nameserver 172.17.118.8 mgmt-edge2-subnet

openstack network create --provider-physical-network sriov1 --provider-network-type vlan --provider-segment 205 backhaul1-net
uuid=$(openstack network segment list --network backhaul1-net -f value -c ID)
openstack network segment set --name backhaul1-central $uuid
openstack subnet create --network backhaul1-net --no-dhcp --network-segment backhaul1-central --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 backhaul1-subnet
openstack network segment create --network backhaul1-net --physical-network sriov1-edge1 --network-type vlan --segment 1205  backhaul1-edge1
openstack subnet create --network backhaul1-net --no-dhcp --network-segment backhaul1-edge1 --subnet-range 192.168.205.64/26 --gateway 192.168.205.126 backhaul1-edge1-subnet
openstack network segment create --network backhaul1-net --physical-network sriov1-edge2 --network-type vlan --segment 2205 backhaul1-edge2
openstack subnet create --network backhaul1-net --no-dhcp --network-segment backhaul1-edge2 --subnet-range 192.168.205.128/26 --gateway 192.168.205.190 backhaul1-edge2-subnet
openstack network create --provider-physical-network sriov2 --provider-network-type vlan --provider-segment 205 backhaul2-net
uuid=$(openstack network segment list --network backhaul2-net -f value -c ID)
openstack network segment set --name backhaul2-central $uuid
openstack subnet create --network backhaul2-net --no-dhcp --network-segment backhaul2-central --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 backhaul2-subnet
openstack network segment create --network backhaul2-net --physical-network sriov1-edge2 --network-type vlan --segment 1205  backhaul2-edge1
openstack subnet create --network backhaul2-net --no-dhcp --network-segment backhaul2-edge1 --subnet-range 192.168.205.64/26 --gateway 192.168.205.126 backhaul2-edge1-subnet
openstack network segment create --network backhaul2-net --physical-network sriov2-edge2 --network-type vlan --segment 2205 backhaul2-edge2
openstack subnet create --network backhaul2-net --no-dhcp --network-segment backhaul2-edge2 --subnet-range 192.168.205.128/26 --gateway 192.168.205.190 backhaul2-edge2-subnet

openstack network create --provider-physical-network sriov1 --provider-network-type vlan --provider-segment 205 midhaul1-net
uuid=$(openstack network segment list --network midhaul1-net -f value -c ID)
openstack network segment set --name midhaul1-central $uuid
openstack subnet create --network midhaul1-net --no-dhcp --network-segment midhaul1-central --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 midhaul1-subnet
openstack network segment create --network midhaul1-net --physical-network sriov1-edge1 --network-type vlan --segment 1205  midhaul1-edge1
openstack subnet create --network midhaul1-net --no-dhcp --network-segment midhaul1-edge1 --subnet-range 192.168.205.64/26 --gateway 192.168.205.126 midhaul1-edge1-subnet
openstack network segment create --network midhaul1-net --physical-network sriov1-edge2 --network-type vlan --segment 2205 midhaul1-edge2
openstack subnet create --network midhaul1-net --no-dhcp --network-segment midhaul1-edge2 --subnet-range 192.168.205.128/26 --gateway 192.168.205.190 midhaul1-edge2-subnet
openstack network create --provider-physical-network sriov2 --provider-network-type vlan --provider-segment 205 midhaul2-net
uuid=$(openstack network segment list --network midhaul2-net -f value -c ID)
openstack network segment set --name midhaul2-central $uuid
openstack subnet create --network midhaul2-net --no-dhcp --network-segment midhaul2-central --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 midhaul2-subnet
openstack network segment create --network midhaul2-net --physical-network sriov1-edge2 --network-type vlan --segment 1205  midhaul2-edge1
openstack subnet create --network midhaul2-net --no-dhcp --network-segment midhaul2-edge1 --subnet-range 192.168.205.64/26 --gateway 192.168.205.126 midhaul2-edge1-subnet
openstack network segment create --network midhaul2-net --physical-network sriov2-edge2 --network-type vlan --segment 2205 midhaul2-edge2
openstack subnet create --network midhaul2-net --no-dhcp --network-segment midhaul2-edge2 --subnet-range 192.168.205.128/26 --gateway 192.168.205.190 midhaul2-edge2-subnet

openstack network create --provider-physical-network fronthaul1 --provider-network-type vlan --provider-segment 203 fronthaul1-net
uuid=$(openstack network segment list --network fronthaul1-net -f value -c ID)
openstack network segment set --name fronthaul1-central $uuid
# not subnet needed for fronthaul1-central
openstack network segment create --network fronthaul1-net --physical-network fronthaul1-edge1 --network-type vlan --segment 1203 fronthaul1-edge1
openstack subnet create --network fronthaul1-net --no-dhcp --network-segment fronthaul1-edge1 --subnet-range 192.168.203.64/26 --gateway 192.168.203.126 fronthaul1-edge1-subnet
openstack network segment create --network fronthaul1-net --physical-network fronthaul1-edge2 --network-type vlan --segment 2203 fronthaul1-edge2
openstack subnet create --network fronthaul1-net --no-dhcp --network-segment fronthaul1-edge2 --subnet-range 192.168.203.128/26 --gateway 192.168.203.190 fronthaul1-edge2-subnet
openstack network create --provider-physical-network fronthaul2 --provider-network-type vlan --provider-segment 203 fronthaul2-net
uuid=$(openstack network segment list --network fronthaul2-net -f value -c ID)
openstack network segment set --name fronthaul2-central $uuid
# not subnet needed for fronthaul2-central
openstack network segment create --network fronthaul2-net --physical-network fronthaul2-edge1 --network-type vlan --segment 1203 fronthaul2-edge1
openstack subnet create --network fronthaul2-net --no-dhcp --network-segment fronthaul2-edge1 --subnet-range 192.168.203.64/26 --gateway 192.168.203.126 fronthaul2-edge1-subnet
openstack network segment create --network fronthaul2-net --physical-network fronthaul2-edge2 --network-type vlan --segment 2203 fronthaul2-edge2
openstack subnet create --network fronthaul2-net --no-dhcp --network-segment fronthaul2-edge2 --subnet-range 192.168.203.128/26 --gateway 192.168.203.190 fronthaul2-edge2-subnet

openstack network create --provider-physical-network sriov1 --provider-network-type vlan --provider-segment 204 ar1-net
uuid=$(openstack network segment list --network ar1-net -f value -c ID)
openstack network segment set --name ar1-central $uuid
# not subnet needed for ar1-central
openstack network segment create --network ar1-net --physical-network sriov1-edge1 --network-type vlan --segment 1204 ar1-edge1
openstack subnet create --network ar1-net --no-dhcp --network-segment ar1-edge1 --subnet-range 192.168.204.0/26 --gateway 192.168.204.126 ar1-edge1-subnet
openstack network segment create --network ar1-net --physical-network sriov1-edge2 --network-type vlan --segment 2204 ar1-edge2
openstack subnet create --network ar1-net --no-dhcp --network-segment ar1-edge2 --subnet-range 192.168.204.128/26 --gateway 192.168.204.190 ar1-edge2-subnet
openstack network create --provider-physical-network sriov2 --provider-network-type vlan --provider-segment 204 ar2-net
uuid=$(openstack network segment list --network ar2-net -f value -c ID)
openstack network segment set --name ar2-central $uuid
# not subnet needed for ar2-central
openstack network segment create --network ar2-net --physical-network sriov2-edge1 --network-type vlan --segment 1204 ar2-edge1
openstack subnet create --network ar2-net --no-dhcp --network-segment ar2-edge1 --subnet-range 192.168.204.0/26 --gateway 192.168.204.126 ar2-edge1-subnet
openstack network segment create --network ar2-net --physical-network sriov2-edge2 --network-type vlan --segment 2204 ar2-edge2
openstack subnet create --network ar2-net --no-dhcp --network-segment ar2-edge2 --subnet-range 192.168.204.128/26 --gateway 192.168.204.190 ar2-edge2-subnet

# increase quotas for admin project
openstack quota set --cores 200 --instances 100 --ram 500000 --volumes 100 --secgroups 100 --volumes 100 --gigabytes 3072 admin
openstack keypair create  --public-key ~/.ssh/id_rsa.pub undercloud-key

# fixup Availability zones
openstack aggregate create --zone edge1vdu edge1vdu || true
openstack aggregate create --zone edge2vdu edge2vdu || true
openstack aggregate remove host edge1 edge1-computevdu-e1-0.lab.local || true
openstack aggregate remove host edge2 edge2-computevdu-e2-0.lab.local || true
openstack aggregate add host edge1vdu edge1-computevdu-e1-0.lab.local || true
openstack aggregate add host edge2vdu edge2-computevdu-e2-0.lab.local || true

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
# seems to be some sort of cli bug, so for now creating policy groups through horizon
# for GROUP in management backhaul1 midhaul1 fronthaul1 ar1; do
# openstack server group create --policy anti-affinity $GROUP
# done

# Create central VMs 1 net per VM
for EDGE in central; do
for NETWORK in backhaul1 midhaul1 management; do
for SERVER in {1..5}; do

if [[ $NETWORK = "management" ]]
then
  VNIC=''
else
  VNIC='--vnic-type direct'
fi

PORT=$(openstack port create --network $NETWORK-net $VNIC -f value -c id test-$EDGE-$NETWORK-$SERVER)
GROUP=$(openstack server group show $NETWORK -f value -c id)

openstack server create --flavor m1.small \
--image rhel-77 \
--port $PORT \
--config-drive True \
--availability-zone central \
--key-name undercloud-key \
--user-data ~/admin-user-data.txt \
--hint group=$GROUP \
test-$EDGE-$NETWORK-$SERVER

done
done
done

# Create edge1/2 VMs 1 net per VM
for EDGE in edge1 edge2; do
for SERVER in vcu vdu; do
if [[ $SERVER = "vcu" ]]
then
  AZ=$EDGE
  NETWORKS='midhaul1 management'
else
  AZ="${EDGE}vdu"
  NETWORKS='fronthaul1 midhaul1 ar1 management'
fi

for NETWORK in $NETWORKS; do
if [[ $NETWORK = "management" ]]
then
  VNIC=''
else
  VNIC='--vnic-type direct'
fi

PORT=$(openstack port create --network $NETWORK-net $VNIC -f value -c id test-$EDGE-$SERVER-$NETWORK)
GROUP=$(openstack server group show $NETWORK -f value -c id)

openstack server create --flavor m1.small-dedicated \
--image rhel-77 \
--port $PORT \
--config-drive True \
--availability-zone $AZ \
--key-name undercloud-key \
--user-data ~/admin-user-data.txt \
--hint group=$GROUP \
test-$EDGE-$SERVER-$NETWORK

done
done
done


exit 0
#--------------- cleanup scripts USE WITH CAUTION, deletes all servers and ports for current tenant ---------------------------

for VM in $( openstack server list -f value -c ID );do
openstack server delete $VM
done

for PORT in $( openstack port list -f value -c ID );do
openstack port delete $PORT
done
