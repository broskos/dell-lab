

#############################
# Create Networks as routed provider network#
#############################
openstack network create --provider-physical-network management --provider-network-type vlan --provider-segment 117 management-net
uuid=$(openstack network segment list --network management-net -f value -c ID)
openstack network segment set --name mgmt-central $uuid
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-central --subnet-range 172.17.117.0/26 --gateway 172.17.117.62 --dns-nameserver 172.17.118.8 management-subnet
openstack network segment create --network management-net --physical-network mgmt-edge1 --network-type vlan --segment 1117  mgmt-edge1
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-edge1 --subnet-range 172.17.117.64/26 --gateway 172.17.117.126 --dns-nameserver 172.17.118.8 mgmt-edge1-subnet
openstack network segment create --network management-net --physical-network mgmt-edge2 --network-type vlan --segment 2117 mgmt-edge2
openstack subnet create --network management-net --no-dhcp --network-segment mgmt-edge2 --subnet-range 172.17.117.128/26 --gateway 172.17.117.190 --dns-nameserver 172.17.118.8 mgmt-edge2-subnet

openstack network create --provider-physical-network sriov1 --provider-network-type vlan --provider-segment 202 backhaul1-net
uuid=$(openstack network segment list --network backhaul1-net -f value -c ID)
openstack network segment set --name backhaul1-central $uuid
openstack subnet create --network backhaul1-net --no-dhcp --network-segment backhaul1-central --subnet-range 192.168.202.0/26 --gateway 192.168.202.62 backhaul1-subnet
openstack network segment create --network backhaul1-net --physical-network sriov1-edge1 --network-type vlan --segment 1202  backhaul1-edge1
openstack subnet create --network backhaul1-net --no-dhcp --network-segment backhaul1-edge1 --subnet-range 192.168.202.64/26 --gateway 192.168.202.126 backhaul1-edge1-subnet
openstack network segment create --network backhaul1-net --physical-network sriov1-edge2 --network-type vlan --segment 2202 backhaul1-edge2
openstack subnet create --network backhaul1-net --no-dhcp --network-segment backhaul1-edge2 --subnet-range 192.168.202.128/26 --gateway 192.168.202.190 backhaul1-edge2-subnet
openstack network create --provider-physical-network sriov2 --provider-network-type vlan --provider-segment 202 backhaul2-net
uuid=$(openstack network segment list --network backhaul2-net -f value -c ID)
openstack network segment set --name backhaul2-central $uuid
openstack subnet create --network backhaul2-net --no-dhcp --network-segment backhaul2-central --subnet-range 192.168.202.0/26 --gateway 192.168.202.62 backhaul2-subnet
openstack network segment create --network backhaul2-net --physical-network sriov1-edge2 --network-type vlan --segment 1202  backhaul2-edge1
openstack subnet create --network backhaul2-net --no-dhcp --network-segment backhaul2-edge1 --subnet-range 192.168.202.64/26 --gateway 192.168.202.126 backhaul2-edge1-subnet
openstack network segment create --network backhaul2-net --physical-network sriov2-edge2 --network-type vlan --segment 2202 backhaul2-edge2
openstack subnet create --network backhaul2-net --no-dhcp --network-segment backhaul2-edge2 --subnet-range 192.168.202.128/26 --gateway 192.168.202.190 backhaul2-edge2-subnet

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