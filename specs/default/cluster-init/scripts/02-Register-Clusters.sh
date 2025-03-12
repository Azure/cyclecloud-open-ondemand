#!/bin/bash
# This script registers the cluster with the OOD server. It is run after the OOD server is installed and configured.
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Register Clusters
$script_dir/../files/install.sh register_cluster

#write out current crontab
crontab -l > tempcron
#echo new cron into cron file
echo "0,10,20,30,40,50 * * * *  rm -rf /mnt/cluster-init/ood/default/files/playbooks/register_cluster.ok && /mnt/cluster-init/ood/default/files/install register_cluster >> /opt/cycle/jetpack/logs/register_cluster.out 1>&2" >> tempcron
#install new cron file
crontab tempcron

rm tempcron
