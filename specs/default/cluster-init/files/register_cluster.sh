#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Remove the marker so we can rerun the playbook
rm -rf $script_dir/playbooks/register_cluster.ok 

# Needed to get the jetpack in the path as we are running this script from the cron job
source /etc/profile/cyclecloud.sh 

$script_dir/install.sh register_cluster