#!/bin/bash
# This script installs Open OnDemand (OOD) on AlmaLinux 8.x and Ubuntu 22.04.

# The script performs the following steps:
# 1. Replaces values in the vars.yml file with user-configured values from the CC template.
# 2. Install Ansible and other dependencies.
# 3. Runs the Ansible playbook to configure OOD.
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
script_name="${0##*/}"
script_name="${script_name%.*}"

# Install Ansible and other dependencies
chmod +x $script_dir/../files/*.sh
if [ ! -e prereqs_install.ok ]; then
    $script_dir/../files/prereqs_install.sh
    touch prereqs_install.ok
fi

# Replace values in the vars.yml file with user-configured values from the CC template
VARS_FILE=$script_dir/../files/playbooks/vars.yml

# Entra config - add values here if using Entra
client_id=$(jetpack config ood.entra_client_id) yq -i '.client_id |= strenv(client_id)' $VARS_FILE # Client ID for Entra
entra_map_match=$(jetpack config ood.entra_user_map_match)
entra_map_match=$(echo $entra_map_match | tr '[:upper:]' '[:lower:]')
# If entra_map_match is None, set it to empty
if [ "$entra_map_match" == "none" ]; then
    entra_map_match=""
fi
yq -i '.entra_map_match |= strenv(entra_map_match)' $VARS_FILE # Domain Mapping for Entra
tenant_id=$(jetpack config ood.entra_tenant_id) yq -i '.tenant_id |= strenv(tenant_id)' $VARS_FILE # Tenant ID for Entra, can be certainly automatically retrieved
user_claim=$(jetpack config ood.user_claim) yq -i '.user_claim |= strenv(user_claim)' $VARS_FILE # User Claim for Entra, default is 'upn'

# OOD server name - this can be the FQDN or IP address of the OOD server or the hostname. This will be used to generate the self-signed SSL certificate.
ood_local_ipv4=$(jetpack config cloud.local_ipv4)
ood_fqdn=$(jetpack config ood.server_name) 
# If ood_fqdn is empty, set it to the local IP address
if [ -z "$ood_fqdn" ]; then
    ood_fqdn=$ood_local_ipv4
fi
# If ood_fqdn is None, set it to the local IP address
ood_fqdn=$(echo $ood_fqdn | tr '[:upper:]' '[:lower:]')
if [ "$ood_fqdn" == "none" ]; then
    ood_fqdn=$ood_local_ipv4
fi

ood_fqdn=$ood_fqdn yq -i '.ood_fqdn |= strenv(ood_fqdn)' $VARS_FILE

# Install OOD
timestamp=$(date -u +"%Y-%m%d-%H%M%S")
export ANSIBLE_LOG_PATH=$script_dir/${script_name}-${timestamp}.log
$script_dir/../files/install.sh ood