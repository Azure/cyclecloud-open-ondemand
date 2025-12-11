#!/bin/bash
TARGET=${1:-all}
shift
ANSIBLE_TAGS=$@
set -e
OOD_ANSIBLE_VERSION="v4.0.1"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLAYBOOKS_DIR=$THIS_DIR/playbooks

# Create or use the python venv oodenv environment
PYTHON_ENV_DIR="${THIS_DIR}/oodenv"
if [ ! -d "${PYTHON_ENV_DIR}" ]; then
    python3 -m venv "${PYTHON_ENV_DIR}"
fi
# activate environment
source "${PYTHON_ENV_DIR}/bin/activate"

function run_playbook ()
{
  local playbook=$1
  shift
  local extra_vars_file=$@

  # If running all playbooks and playbook marker doesn't exists, run the playbook
  # If user requested specific playbook ignore marker file and force run
  if [ ! -e $PLAYBOOKS_DIR/$playbook.ok ] ; then
    local options=""
    if [ "$extra_vars_file" != "" ]; then
      # Merge overrides variables in a single file
      yq eval-all '. as $item ireduce ({}; . *+ $item)' $extra_vars_file > $PLAYBOOKS_DIR/extra_vars.yml
      options+=" --extra-vars=@$PLAYBOOKS_DIR/extra_vars.yml"
    fi
    echo "Running playbook $PLAYBOOKS_DIR/$playbook.yml ..."
    ansible-playbook $PLAYBOOKS_DIR/$playbook.yml $options $ANSIBLE_TAGS || exit 1
    if [ -e $PLAYBOOKS_DIR/extra_vars.yml ]; then
      rm $PLAYBOOKS_DIR/extra_vars.yml
    fi
    touch $PLAYBOOKS_DIR/$playbook.ok
  else
    echo "Skipping playbook $PLAYBOOKS_DIR/$playbook.yml as it has been successfully run "
  fi
}

# Ensure submodule exists
if [ ! -d "${PLAYBOOKS_DIR}/roles/ood-ansible/.github" ]; then
    printf "Installing OOD Ansible submodule\n"
    git clone -b $OOD_ANSIBLE_VERSION https://github.com/OSC/ood-ansible.git $PLAYBOOKS_DIR/roles/ood-ansible
fi

# This trick is to avoid the error when running the OOD tasks handlers with errors like these:
# Ignoring bcrypt-3.1.16 because its extensions are not built. Try: gem pristine bcrypt --version 3.1.16
export PATH=/usr/bin:$PATH
export ANSIBLE_VERBOSITY=2

case $TARGET in
  all)
    run_playbook ood $PLAYBOOKS_DIR/vars-ood.yml
    run_playbook register_cluster
  ;;
  register_cluster)
    run_playbook $TARGET
  ;;
  ood)
    run_playbook ood $PLAYBOOKS_DIR/vars-ood.yml
  ;;
  *)
    echo "unknown target"
    exit 1
  ;;
esac
