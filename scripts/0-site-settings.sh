

# these are used for RT Image, script needs updated for satellite
#export pool='8a85f98c60c2c2b40160c32447481b48'
#export cdn_user='broskos@redhat.com'
export cdn_user='abokhari@redhat.com'
export pool='8a85f9996f0fa058016f7de6ac642eba'

# then we use regular satellite
export satellite=satellite.lab.roskosb.info
export org=lab
export director_activation_key='osp16-director-dev'


export hostname='director'
export ip_address='172.17.118.10'
export domain='lab.roskosb.info'
export stack_password='redhat'
export osp_version='16'
export template_path='~/dell-lab/templates'

export stack_name='vranlab'


home=~
rcfile=$home/$stack_name
rcfile+="rc"
export rcfile
