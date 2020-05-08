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
#openstack image create --public --file ~/images/rhel-server-77-RT.qcow2 --disk-format qcow2 --container bare rhel-server-77-RT

##########################
# Create Default Flavors #
##########################
openstack flavor create --ram 2048 --disk 20 --vcpus 1 m1.small

#############################
# Create Management Network as routed provider network#
#############################
openstack network create --provider-physical-network management --provider-network-type vlan --provider-segment 117 management-net
uuid=$(openstack network segment list --network management-net -f value -c ID)
openstack network segment set --name mgmt-central $uuid
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-central --subnet-range 172.17.117.0/26 --gateway 172.17.117.62 --dns-nameserver 172.17.118.8 management-subnet
openstack network segment create --network management-net --physical-network mgmt-edge1 --network-type vlan --segment 117  mgmt-edge1
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-edge1 --subnet-range 172.17.117.64/26 --gateway 172.17.117.62 --dns-nameserver 172.17.118.8 mgmt-edge1-subnet
openstack network segment create --network management-net --physical-network mgmt-edge2 --network-type vlan --segment 117 mgmt-edge2
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-edge2 --subnet-range 172.17.117.128/26 --gateway 172.17.117.126 --dns-nameserver 172.17.118.8 mgmt-edge2-subnet

openstack network create --provider-physical-network sriov-1 --provider-network-type vlan --provider-segment 202 backhaul1-net
openstack subnet create --network backhaul1-net --no-dhcp --subnet-range 192.168.202.0/26 --gateway 192.168.202.62  backhaul1-subnet
openstack network create --provider-physical-network sriov-2 --provider-network-type vlan --provider-segment 202 backhaul2-net
openstack subnet create --network backhaul2-net --no-dhcp --subnet-range 192.168.202.0/26 --gateway 192.168.202.62  backhaul2-subnet

openstack network create --provider-physical-network sriov-1 --provider-network-type vlan --provider-segment 205 midhaul1-net
uuid=$(openstack network segment list --network midhaul1-net -f value -c ID)
openstack network segment set --name midhaul1-central $uuid
openstack subnet create --network midhaul1-net --no-dhcp --network-segment midhaul1-central --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 --dns-nameserver 172.17.118.8 midhaul1-subnet
openstack network segment create --network midhaul1-net --physical-network sriov-edge1-1 --network-type vlan --segment 1205  midhaul1-edge1
openstack subnet create --network midhaul1-net --no-dhcp --network-segment midhaul1-edge1 --subnet-range 192.168.205.64/26 --gateway 192.168.205.62 --dns-nameserver 172.17.118.8 mgmt-edge1-subnet
openstack network segment create --network midhaul1-net --physical-network sriov-edge2-1 --network-type vlan --segment 2205 midhaul1-edge2
openstack subnet create --network midhaul1-net --no-dhcp --network-segment midhaul1-edge2 --subnet-range 192.168.205.128/26 --gateway 192.168.205.126 --dns-nameserver 172.17.118.8 mgmt-edge2-subnet
openstack network create --provider-physical-network sriov-2 --provider-network-type vlan --provider-segment 205 midhaul2-net
uuid=$(openstack network segment list --network midhaul2-net -f value -c ID)
openstack network segment set --name midhaul2-central $uuid
openstack subnet create --network midhaul2-net --no-dhcp --network-segment midhaul2-central --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 --dns-nameserver 172.17.118.8 midhaul2-subnet
openstack network segment create --network midhaul2-net --physical-network sriov-edge1-2 --network-type vlan --segment 1205  midhaul2-edge1
openstack subnet create --network midhaul2-net --no-dhcp --network-segment midhaul2-edge1 --subnet-range 192.168.205.64/26 --gateway 192.168.205.62 --dns-nameserver 172.17.118.8 midhaul2-edge1-subnet
openstack network segment create --network midhaul2-net --physical-network sriov-edge2-2 --network-type vlan --segment 2205 midhaul2-edge2
openstack subnet create --network midhaul2-net --no-dhcp --network-segment midhaul2-edge2 --subnet-range 192.168.205.128/26 --gateway 192.168.205.126 --dns-nameserver 172.17.118.8 midhaul2-edge2-subnet

openstack network create --provider-physical-network sriov-edge1-1 --provider-network-type vlan --provider-segment 1203 fronthaul1-net
uuid=$(openstack network segment list --network fronthaul1-net -f value -c ID)
openstack network segment set --name fronthaul1-edge1 $uuid
openstack subnet create --network fronthaul1-net --no-dhcp --network-segment fronthaul1-edge1 --subnet-range 192.168.203.0/26 --gateway 192.168.203.62 --dns-nameserver 172.17.118.8 fronthaul1-subnet
openstack network segment create --network fronthaul1-net --physical-network sriov-edge2-1 --network-type vlan --segment 2203 fronthaul1-edge2
openstack subnet create --network fronthaul1-net --no-dhcp --network-segment fronthaul1-edge2 --subnet-range 192.168.203.128/26 --gateway 192.168.203.126 --dns-nameserver 172.17.118.8 fronthaul1-edge2-subnet
openstack network create --provider-physical-network sriov-edge1-2 --provider-network-type vlan --provider-segment 1203 fronthaul2-net
uuid=$(openstack network segment list --network fronthaul2-net -f value -c ID)
openstack network segment set --name fronthaul2-edge1 $uuid
openstack subnet create --network fronthaul2-net --no-dhcp --network-segment fronthaul2-edge1 --subnet-range 192.168.203.0/26 --gateway 192.168.203.62 --dns-nameserver 172.17.118.8 fronthaul2-subnet
openstack network segment create --network fronthaul2-net --physical-network sriov-edge2-2 --network-type vlan --segment 2203 fronthaul2-edge2
openstack subnet create --network fronthaul2-net --no-dhcp --network-segment fronthaul2-edge2 --subnet-range 192.168.203.128/26 --gateway 192.168.203.126 --dns-nameserver 172.17.118.8 fronthaul2-edge2-subnet


# increase quotas for admin project
openstack quota set --cores 200 --instances 100 --ram 500000 --volumes 100 --secgroups 100 --volumes 100 --gigabytes 3072 admin
