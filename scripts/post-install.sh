#################################
# Upload RHEL 7 Image to Glance
#################################
openstack image create --public --file ~/images/rhel-server-7.7-x86_64-kvm.qcow2 --disk-format qcow2 --container bare rhel-77

##########################
# Create Default Flavors #
##########################
openstack flavor create --ram 2048 --disk 20 --vcpus 1 m1.small

#############################
# Create Management Network #
#############################
openstack network create --project admin --no-share  --provider-network-type vlan --provider-segment 117 --provider-physical-network management management-net
openstack subnet create --project admin --network management-net --dhcp --subnet-range 172.17.117.0/24 --gateway 172.17.117.254 --allocation-pool start=172.17.117.150,end=172.17.117.250 --dns-nameserver 172.17.118.8 management


######################################
# create host aggregates             #
# to separate edge and central sites #
######################################
openstack aggregate create central
openstack aggregate create edge1
openstack aggregate create edge1vdu
openstack aggregate create edge2
openstack aggregate create edge2vdu

# add computes to central site
for vm_host in $(openstack hypervisor list -f value -c "Hypervisor Hostname" | grep compute); do
 openstack aggregate add host central $vm_host
done

# add computes to edge1 site
for vm_host in $(openstack hypervisor list -f value -c "Hypervisor Hostname" | grep edge1); do
  if [[ $vm_host == *"edge1vdu"* ]]; then
    openstack aggregate add host edge1vdu $vm_host
  else
    openstack aggregate add host edge1 $vm_host
  fi
done

# add computes to edge2 site
for vm_host in $(openstack hypervisor list -f value -c "Hypervisor Hostname" | grep edge2); do
  if [[ $vm_host == *"edge2vdu"* ]]; then
    openstack aggregate add host edge2vdu $vm_host
  else
    openstack aggregate add host edge2 $vm_host
  fi
done