#
# Run the following commands after connecting to Ceph MON container
# podman exec -it 9a2199f4e48b /bin/bash
#
# Create the pools
#
ceph osd pool create volumes 128
ceph osd pool create images 64
ceph osd pool create vms 128
ceph osd pool create backups 64

#
# Create client.openstack user
#
ceph auth add client.openstack mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rwx pool=images, allow rwx pool=backups'

#
# Get the ceph client key for the new user
#
ceph auth list

#
# Get the file system ID
#
grep fsid /etc/ceph/ceph.conf

