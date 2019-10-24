#!/usr/bin/env bash

# assumes server idrac on 172.17.120.0/24
USER=root
PASSWORD=calvin
NET=172.17.120

for serverIP in 7 9 11 31 13 37 33
do
  echo "working on: $NET.$serverIP"
  racadm -r $NET.$serverIP -u $USER -p $PASSWORD set  bios.BiosBootSettings.BootMode Bios
  racadm -r $NET.$serverIP -u $USER -p $PASSWORD jobqueue create BIOS.Setup.1-1
  racadm -r $NET.$serverIP -u $USER -p $PASSWORD serveraction hardreset
done
