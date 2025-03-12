#!/bin/bash
# This script registers the cluster with the OOD server. It is run after the OOD server is installed and configured.
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Register Clusters
REGISTER_CLUSTER_SCRIPT=$script_dir/../files/register_cluster.sh
chmod +x $REGISTER_CLUSTER_SCRIPT
$REGISTER_CLUSTER_SCRIPT

cron_command="$REGISTER_CLUSTER_SCRIPT >> /opt/cycle/jetpack/logs/register_cluster.out 2>&1"
cron_job="0,10,20,30,40,50 * * * * $cron_command"

set +e # to avoid error if crontab is empty
(crontab -l | grep -v -F "$cron_command" ; echo "$cron_job") | crontab -
