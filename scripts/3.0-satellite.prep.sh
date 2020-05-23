#!/usr/bin/env bash
## this can be run from the satellite server, but you need jq
# run this on director or local machine with jq installed then scp to root@satellite

UPSTREAM_URL="registry.redhat.io"
curl -s https://${UPSTREAM_URL}/v1/search?q=%27rhosp-rhel8%20or%20rhceph-4%20or%20ose-grafana%20or%20ose-prometheus%27|jq -r .results[].name > satellite_images
scp satellite_images root@satellite.lab.roskosb.info:

# Create a registry service account:
# https://access.redhat.com/RegistryAuthentication

# insert your registry service account credentials here:
export USERNAME="5318211|broskos-dell-lab"
export PASSWORD="eyJhbGciOiJSUzUxMiJ9.eyJzdWIiOiI1MTVlODNiY2E2ZjU0NzI1YmY3ZmRkN2NhMDgzMWE2OCJ9.LccMloFAf3SY9LDkh6wXsECLxmgYopnU_RUeShXSvNzA8DJj5-9w-7pZtSSm00sg0wGt19fmJmFd2MOlGwtzFmKtpSsO0C0PuO9M4M8wWGPITe-dCJcSQAkpl_xg-n6m2EY1IxkZ0K35-BSNfc7OJ95f2lVQc_UBRXc5BLm5OU4z_BeI43wMK2w3bXi_XGj4cmuGw2gg4JBQng-6lSy7auQX_Ad_Y9poNPX40lBtGD93Pe-lZfbAXXOK21V52GfLzAIOWSUkMbtvW_c69-d3i-fGHiSmVUVQGEMxv_zfujlvIuDZ4R4xLnMnBjvqpzZKzlWwNIar8gc6PSarPPdvyacCQTT3C7aRh-Pnj3E-dVrLHnj-ZW2pyjly0FIMOASPdapsK_wjYc5Z35_8hwvClIrS3oSdqWHWu8pB-iHVrdbIhwjxfVneaFMK9nw_ELeb0E_yryHj-cQzXtF0gU7_-pBiSQbXjW0bxxfLNFj_-ENjyodo9-t635CR8_5LCvft8jiBZWIAXr_Ll4aD53tFFAzuTmc9_SsIuBniEOxLdU61mgVe8aIa4lRD-9IlXVeKHq39jIYHwdBQ7YXO-u7mneNMJy4-_s7FS3B_dSsCoyQ5V4DYa3ocTbfFue8mTlcpv1YewSTODJeR2lWlRL-rq7weLUqX5yF-EnVYPAiJaLI"


MY_ORG="lab"
MY_PRODUCT="osp16_containers"
MY_LE="dev"
UPSTREAM_URL="registry.redhat.io"
SATELLITE_SERVER="satellite.lab.roskosb.info"
TEMPLATE_PATH="~/dell-lab/templates"

hammer product create \
  --organization "${MY_ORG}" \
  --name "${MY_PRODUCT}"

hammer repository create \
  --organization "${MY_ORG}" \
  --product "${MY_PRODUCT}" \
  --content-type docker \
  --url https://${UPSTREAM_URL} \
  --docker-upstream-name rhosp-rhel8/openstack-base \
  --upstream-username $USERNAME \
  --upstream-password $PASSWORD \
  --name base

while read IMAGE; do \
  IMAGENAME=$(echo $IMAGE | cut -d"/" -f2 | sed "s/openstack-//g" | sed "s/:.*//g") ; \
  hammer repository create \
  --organization "${MY_ORG}" \
  --product "${MY_PRODUCT}" \
  --content-type docker \
  --url https://${UPSTREAM_URL} \
  --docker-upstream-name $IMAGE \
  --upstream-username $USERNAME \
  --upstream-password $PASSWORD \
  --name $IMAGENAME ; done < satellite_images


# RHEL repos need --releasever
declare -a REPOS=(
"Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)"
"Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)"
"Red Hat Enterprise Linux 8 for x86_64 - High Availability (RPMs)"
"Red Hat Enterprise Linux 8 for x86_64 - Real Time for NFV (RPMs)"
)

for REPO in "${REPOS[@]}"; do
  echo "Working on: ${REPO}"
  hammer repository-set enable \
  --organization "${MY_ORG}" \
  --releasever 8.1 \
  --name "${REPO}"
done

# Other repos cant have --releasever
declare -a REPOS=(
"Red Hat Ansible Engine 2.8 for RHEL 8 x86_64 (RPMs)"
"Advanced Virtualization for RHEL 8 x86_64 (RPMs)"
"Red Hat Satellite Tools 6.5 for RHEL 8 x86_64 (RPMs)"
"Red Hat OpenStack Platform 16 for RHEL 8 x86_64 (RPMs)"
"Fast Datapath for RHEL 8 x86_64 (RPMs)"
"Red Hat Ceph Storage Tools 4 for RHEL 8 x86_64 (RPMs)"
"Red Hat CodeReady Linux Builder for RHEL 8 x86_64 (RPMs)"
)

for REPO in "${REPOS[@]}"; do
  echo "Working on: ${REPO}"
  hammer repository-set enable \
  --organization "${MY_ORG}" \
  --name "${REPO}"
done

#create sync plan, add products, do initial sync
hammer sync-plan create \
--description "Nightly" \
--organization "${MY_ORG}" \
--name "Nightly" \
--interval "daily" \
--enabled "True" \
--sync-date "`date +'%Y-%m-%d'` 23:00:00"

declare -a PRODUCTS=(
"Red Hat Ansible Engine"
"Red Hat Ceph Storage"
"Red Hat Enterprise Linux Advanced Virtualization"
"Red Hat Enterprise Linux Fast Datapath"
"Red Hat Enterprise Linux for x86_64"
"Red Hat Enterprise Linux High Availability for x86_64"
"Red Hat OpenStack"
"osp16_containers"
)

for PRODUCT in "${PRODUCTS[@]}"; do
hammer product set-sync-plan \
--organization "${MY_ORG}" \
--sync-plan "Nightly" \
--name "${PRODUCT}"
done

# cant find a way to trigger the sync-plan, so conduct the intial sync for each product
for PRODUCT in "${PRODUCTS[@]}"; do
hammer product synchronize \
--organization "${MY_ORG}" \
--name "${PRODUCT}" \
--async
done

# TODO: Create content view & activation key
