#!/usr/bin/env bash

# assumes server idrac on 172.17.120.0/24
USER=root
PASSWORD=calvin
NET=172.17.120

for SERVERIP in 7 9 11 13 15 31 13 37 33 35
do
  echo "working on: $NET.$SERVERIP"
# usefull for clearing out stuck jobqueue:
# racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD jobqueue delete -i JID_CLEARALL_FORCE

  racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD set BIOS.BiosBootSettings.BootMode Bios
# some systems have the AHCI in a different slot, one of these will error, but whichever is valid should still work
  racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD set BIOS.BiosBootSettings.HddSeq AHCI.Slot.4-1,NonRAID.Slot.6-1
  racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD set BIOS.BiosBootSettings.HddSeq AHCI.Slot.5-1,NonRAID.Slot.6-1

  racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD set BIOS.IntegratedDevices.SriovGlobalEnable Enabled
  racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD set BIOS.SysProfileSettings.SysProfile Performance
  racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD set BIOS.SysProfileSettings.WorkloadProfile VtOptimizedProfile
  racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD jobqueue create BIOS.Setup.1-1
  racadm -r $NET.$SERVERIP -u $USER -p $PASSWORD serveraction hardreset
done


