#############################
# Create Management Network as routed provider network#
#############################
openstack network create --provider-physical-network management --provider-network-type vlan --provider-segment 117 management-central-net
openstack subnet create --network management-central-net --no-dhcp --subnet-range 172.17.117.0/26 --gateway 172.17.117.62 --dns-nameserver 172.17.118.8 management-central-subnet
openstack network create --provider-physical-network mgmt-edge1 --provider-network-type vlan --provider-segment 1117 management-edge1-net
openstack subnet create --network management-edge1-net --no-dhcp --subnet-range 172.17.117.64/26 --gateway 172.17.117.126 --dns-nameserver 172.17.118.8 management-edge1-subnet
openstack network create --provider-physical-network mgmt-edge2 --provider-network-type vlan --provider-segment 2117 management-edge2-net
openstack subnet create --network management-edge2-net --no-dhcp --subnet-range 172.17.117.128/26 --gateway 172.17.117.190 --dns-nameserver 172.17.118.8 management-edge2-subnet

openstack network create --provider-physical-network sriov1 --provider-network-type vlan --provider-segment 202 backhaul1-central-net
openstack subnet create --network backhaul1-central-net --no-dhcp --subnet-range 192.168.202.0/26 --gateway 192.168.202.62 backhaul1-central-subnet
openstack network create --provider-physical-network sriov1-edge1 --provider-network-type vlan --provider-segment 1202 backhaul1-edge1-net
openstack subnet create --network backhaul1-edge1-net --no-dhcp --subnet-range 192.168.202.64/26 --gateway 192.168.202.126 backhaul1-edge1-subnet
openstack network create --provider-physical-network sriov1-edge2 --provider-network-type vlan --provider-segment 2202 backhaul1-edge2-net
openstack subnet create --network backhaul1-edge2-net --no-dhcp --subnet-range 192.168.202.128/26 --gateway 192.168.202.190 backhaul1-edge2-subnet
openstack network create --provider-physical-network sriov2 --provider-network-type vlan --provider-segment 202 backhaul2-central-net
openstack subnet create --network backhaul2-central-net --no-dhcp --subnet-range 192.168.202.0/26 --gateway 192.168.202.62 backhaul2-central-subnet
openstack network create --provider-physical-network sriov2-edge1 --provider-network-type vlan --provider-segment 1202 backhaul2-edge1-net
openstack subnet create --network backhaul2-edge1-net --no-dhcp --subnet-range 192.168.202.64/26 --gateway 192.168.202.126 backhaul2-edge1-subnet
openstack network create --provider-physical-network sriov2-edge2 --provider-network-type vlan --provider-segment 2202 backhaul2-edge2-net
openstack subnet create --network backhaul2-edge2-net --no-dhcp --subnet-range 192.168.202.128/26 --gateway 192.168.202.190 backhaul2-edge2-subnet

openstack network create --provider-physical-network sriov1 --provider-network-type vlan --provider-segment 205 midhaul1-central-net
openstack subnet create --network midhaul1-central-net --no-dhcp --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 midhaul1-central-subnet
openstack network create --provider-physical-network sriov1-edge1 --provider-network-type vlan --provider-segment 1205 midhaul1-edge1-net
openstack subnet create --network midhaul1-edge1-net --no-dhcp --subnet-range 192.168.205.64/26 --gateway 192.168.205.126 midhaul1-edge1-subnet
openstack network create --provider-physical-network sriov1-edge2 --provider-network-type vlan --provider-segment 2205 midhaul1-edge2-net
openstack subnet create --network midhaul1-edge2-net --no-dhcp --subnet-range 192.168.205.128/26 --gateway 192.168.205.190 midhaul1-edge2-subnet
openstack network create --provider-physical-network sriov2 --provider-network-type vlan --provider-segment 205 midhaul2-central-net
openstack subnet create --network midhaul2-central-net --no-dhcp --subnet-range 192.168.205.0/26 --gateway 192.168.205.62 midhaul2-central-subnet
openstack network create --provider-physical-network sriov2-edge1 --provider-network-type vlan --provider-segment 1205 midhaul2-edge1-net
openstack subnet create --network midhaul2-edge1-net --no-dhcp --subnet-range 192.168.205.64/26 --gateway 192.168.205.126 midhaul2-edge1-subnet
openstack network create --provider-physical-network sriov2-edge2 --provider-network-type vlan --provider-segment 2205 midhaul2-edge2-net
openstack subnet create --network midhaul2-edge2-net --no-dhcp --subnet-range 192.168.205.128/26 --gateway 192.168.205.190 midhaul2-edge2-subnet

openstack network create --provider-physical-network fronthaul1-edge1 --provider-network-type vlan --provider-segment 1203 fronthaul1-edge1-net
openstack subnet create --network fronthaul1-edge1-net --no-dhcp --subnet-range 192.168.203.64/26 --gateway 192.168.203.126 fronthaul1-edge1-subnet
openstack network create --provider-physical-network fronthaul1-edge2 --provider-network-type vlan --provider-segment 2203 fronthaul1-edge2-net
openstack subnet create --network fronthaul1-edge2-net --no-dhcp --subnet-range 192.168.203.128/26 --gateway 192.168.203.190 fronthaul1-edge2-subnet
openstack network create --provider-physical-network fronthaul2-edge1 --provider-network-type vlan --provider-segment 1203 fronthaul2-edge1-net
openstack subnet create --network fronthaul2-edge1-net --no-dhcp --subnet-range 192.168.203.64/26 --gateway 192.168.203.126 fronthaul2-edge1-subnet
openstack network create --provider-physical-network fronthaul2-edge2 --provider-network-type vlan --provider-segment 2203 fronthaul2-edge2-net
openstack subnet create --network fronthaul2-edge2-net --no-dhcp --subnet-range 192.168.203.128/26 --gateway 192.168.203.190 fronthaul2-edge2-subnet

openstack network create --provider-physical-network sriov1-edge1 --provider-network-type vlan --provider-segment 1204 ar1-edge1-net
openstack subnet create --network ar1-edge1-net --no-dhcp --subnet-range 192.168.204.0/26 --gateway 192.168.204.126 ar1-edge1-subnet
openstack network create --provider-physical-network sriov1-edge2 --provider-network-type vlan --provider-segment 2204 ar1-edge2-net
openstack subnet create --network ar1-edge2-net --no-dhcp --subnet-range 192.168.204.128/26 --gateway 192.168.204.190 ar1-edge2-subnet
openstack network create --provider-physical-network sriov2-edge1 --provider-network-type vlan --provider-segment 1204 ar2-edge1-net
openstack subnet create --network ar2-edge1-net --no-dhcp --subnet-range 192.168.204.0/26 --gateway 192.168.204.126 ar2-edge1-subnet
openstack network create --provider-physical-network sriov2-edge2 --provider-network-type vlan --provider-segment 2204 ar2-edge2-net
openstack subnet create --network ar2-edge2-net --no-dhcp --subnet-range 192.168.204.128/26 --gateway 192.168.204.190 ar2-edge2-subnet
