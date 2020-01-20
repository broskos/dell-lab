cd /home/heat-admin/dpdk
modprobe uio
insmod ./x86_64-native-linuxapp-gcc/build/kernel/linux/igb_uio/igb_uio.ko

vendor=1172
pf_device=5052
vf_device=5050

echo "${vendor} ${pf_device}" > /sys/bus/pci/drivers/igb_uio/new_id

cd /root
./config_bbdev FPGA -c fpga_config.cfg -a -f 2

modprobe vfio-pci
echo "${vendor} ${vf_device}" > /sys/bus/pci/drivers/vfio-pci/new_id