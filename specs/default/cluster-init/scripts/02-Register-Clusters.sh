#!/bin/bash
# This script registers the cluster with the OOD server. It is run after the OOD server is installed and configured.
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Register Clusters
$script_dir/../files/install.sh register_cluster