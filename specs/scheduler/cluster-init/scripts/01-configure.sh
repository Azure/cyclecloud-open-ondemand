#!/bin/bash
set -e
files_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../files" && pwd )"
OOD_CLUSTER_DIR="/shared/ood/config/clusters.d"

# Create the cluster definitions on the shared directory
mkdir -pv $OOD_CLUSTER_DIR

# TODO:
# - Retrieve the cluster name and login node names
# - Update clusters definition files
# - Copy clusters definition files to the shared directory
CLUSTER_NAME="ccw"

# Copy clusters definition files to the shared directory
cp -fv ${files_dir}/login_cluster.yml $OOD_CLUSTER_DIR/login_slurm_$CLUSTER_NAME.yml
cp -fv ${files_dir}/slurm_cluster.yml $OOD_CLUSTER_DIR/slurm_$CLUSTER_NAME.yml

# Copy slurm command wrapper scripts to the shared directory
mkdir -pv $OOD_CLUSTER_DIR/slurm_$CLUSTER_NAME
cp -fv "${files_dir}/slurm_proxy.sh" "${files_dir}/sacctmgr.sh" "${files_dir}/sbatch.sh" "${files_dir}/scancel.sh" "${files_dir}/scontrol.sh" "${files_dir}/sinfo.sh" "${script_dir}/squeue.sh" $OOD_CLUSTER_DIR
