source ~/dell-lab/scripts/0-site-settings.sh
source ~/central
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
openstack network segment set --name central $uuid
openstack subnet create --network management-net --no-dhcp --network-segment central --subnet-range 172.17.117.0/26 --gateway 172.17.117.62 --dns-nameserver 172.17.118.8 management-subnet
openstack network segment create --network management-net --physical-network mgmt-edge1 --network-type vlan --segment 117  edge1
openstack subnet create --network management-net --no-dhcp --network-segment edge1 --subnet-range 172.17.117.64/26 --gateway 172.17.117.62 --dns-nameserver 172.17.118.8 mgmt-edge1-subnet
openstack network segment create --network management-net --physical-network mgmt-edge2 --network-type vlan --segment 117 edge2
openstack subnet create --network management-net --no-dhcp --network-segment edge2 --subnet-range 172.17.117.128/26 --gateway 172.17.117.126 --dns-nameserver 172.17.118.8 mgmt-edge2-subnet
# increase quotas for admin project
openstack quota set --cores 200 --instances 100 --ram 500000 --volumes 100 --secgroups 100 --volumes 100 --gigabytes 3072 admin
