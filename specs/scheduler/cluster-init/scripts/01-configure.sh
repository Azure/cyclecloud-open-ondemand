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
CLUSTER_NAME=$(jetpack config cyclecloud.cluster.name)
NODE_PREFIX="${CLUSTER_NAME}-"
BIN_OVERRIDES=$OOD_CLUSTER_DIR/slurm_$CLUSTER_NAME/bin_overrides

# Copy clusters definition files to the shared directory
cp -fv ${files_dir}/login_cluster.yml $OOD_CLUSTER_DIR/login_slurm_$CLUSTER_NAME.yml
cp -fv ${files_dir}/slurm_cluster.yml $OOD_CLUSTER_DIR/slurm_$CLUSTER_NAME.yml

sed -i "s/__CLUSTER_NAME__/${CLUSTER_NAME}/g" $OOD_CLUSTER_DIR/slurm_$CLUSTER_NAME.yml
sed -i "s/__BIN_OVERRIDES_DIR__/${BIN_OVERRIDES}/g" $OOD_CLUSTER_DIR/slurm_$CLUSTER_NAME.yml
sed -i "s/__NODE_PREFIX__/${NODE_PREFIX}/g" $OOD_CLUSTER_DIR/slurm_$CLUSTER_NAME.yml
sed -i "s/__NODE_PREFIX__/${NODE_PREFIX}/g" $OOD_CLUSTER_DIR/login_slurm_$CLUSTER_NAME.yml

# Copy slurm command wrapper scripts to the shared directory
mkdir -pv $BIN_OVERRIDES
cp -fv "${files_dir}/slurm_proxy.sh" "${files_dir}/sacctmgr.sh" "${files_dir}/sbatch.sh" "${files_dir}/scancel.sh" "${files_dir}/scontrol.sh" "${files_dir}/sinfo.sh" "${files_dir}/squeue.sh" $BIN_OVERRIDES

# Update the scheduler name in the slurm proxy script
SCHEDULER=$(hostname)
sed -i "s/__SCHEDULER__/${SCHEDULER}/g" $BIN_OVERRIDES/slurm_proxy.sh

chmod +x $BIN_OVERRIDES/*.sh

