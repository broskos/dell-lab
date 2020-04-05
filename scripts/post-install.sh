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
# Create Management Network #
#############################
openstack network create --project admin --no-share --provider-network-type vlan --provider-segment 117 --provider-physical-network management management-net
openstack subnet create --project admin --network management-net --no-dhcp --subnet-range 172.17.117.0/24 --gateway 172.17.117.254 --allocation-pool start=172.17.117.2,end=172.17.117.100 --dns-nameserver 172.17.118.8 management-subnet

# increase quotas for admin project
openstack quota set --cores 200 --instances 100 --ram 500000 --volumes 100 --secgroups 100 --volumes 100 --gigabytes 3072 admin
