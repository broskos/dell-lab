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