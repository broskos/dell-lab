source ~/dell-lab/scripts/0-site-settings.sh
source ~/vranlabrc

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


######################################
# create host aggregates             #
# to separate edge and central sites #
######################################
openstack aggregate create --zone central central
openstack aggregate create --zone edge1 edge1
openstack aggregate create --zone edge1vdu edge1vdu
openstack aggregate create --zone edge2 edge2
openstack aggregate create --zone edge2vdu edge2vdu

# add computes to central site
for vm_host in compute-0 compute-1 computehci-0 computehci-1 computehci-2; do
 openstack aggregate add host central "vranlab-$vm_host.lab.local"
done

# add computes to edge1 site
openstack aggregate add host edge1 vranlab-compute-e1-0.lab.local
openstack aggregate add host edge1vdu vranlab-computevdu-e1-0.lab.local

# add computes to edge2 site
openstack aggregate add host edge2 vranlab-compute-e2-0.lab.local
openstack aggregate add host edge2vdu vranlab-computevdu-e2-0.lab.local

# increase quotas for admin project
openstack quota set --cores 200 --instances 100 --ram 500000 --volumes 100 --secgroups 100 --volumes 100 --gigabytes 3072 admin
