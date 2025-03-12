#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bash "${script_dir}/slurm_proxy.sh" squeue $@
