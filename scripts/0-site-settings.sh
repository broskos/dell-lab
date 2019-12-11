

# these are used for RT Image, script needs updated for satellite
export pool='8a85f9996977b23d0169d99b5860315d'
export cdn_user='broskos@redhat.com'

# then we use regular satellite
export satellite=satellite.lab.roskosb.info
export org=lab
export director_activation_key='osp13-director-dev'


export hostname='director'
export ip_address='172.17.118.10'
export domain='lab.roskosb.info'
export stack_password='redhat'
export osp_version='13'
export template_path='~/dell-lab/templates'

export stack_name='vranlab'


home=~
rcfile=$home/$stack_name
rcfile+="rc"
export rcfile