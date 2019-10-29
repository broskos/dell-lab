# Dell vRAN Lab *** Dell / Red Hat / Altiostar ***

## Infrastructure servers
### RHHI
- management:  
rhvm.lab.roskosb.info  
https://rhvm.lab.roskosb.info/  
admin / redhat

- packages and containers:  
satellite.lab.roskosb.info  
https://satellite.lab.roskosb.info  
admin /redhat  

- generic rhel7 guest  
rhel76-test.lab.roskosb.info  
root / redhat

- hosts:  
rhhi-1.lab.roskosb.info  
rhhi-2.lab.roskosb.info  
rhhi-3.lab.roskosb.info  

RHHI servers have a hard dependency on DNS, avoid trying to use /etc/hosts, it just causes problems later on.  
    
Compute nodes need to resolve satellite server by name.  

overcloud has a hard dependency on NTP, computes can't access the internet, so make sure NTP is available internally.  Using RHHI servers for internal NTP.  
- to enable, add to /etc/chrony.conf  
allow 192.168.0.0/16  
allow 172.17.0.0/16  
- add ntp service to firewalld


## OpenStack
- director:  
director.lab.lab.roskosb.info  
stack / redhat

- horizon:  
http://overcloud.lab.roskosb.info  
admin / 


