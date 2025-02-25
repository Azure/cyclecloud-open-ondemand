#!/bin/bash
SLURM_CMD=$1
shift

ssh_options="-o StrictHostKeyChecking=no -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null"
ssh ccw-login-1 $ssh_options "$SLURM_CMD $@"
EXIT_CODE=$(echo $?)

exit $EXIT_CODE
