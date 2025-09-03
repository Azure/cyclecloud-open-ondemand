#!/bin/bash
set -e
# Installs Ansible in a python environment.
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

read_os()
{
    os_release=$(cat /etc/os-release | grep "^ID\=" | cut -d'=' -f 2 | xargs)
    os_maj_ver=$(cat /etc/os-release | grep "^VERSION_ID\=" | cut -d'=' -f 2 | xargs)
    full_version=$(cat /etc/os-release | grep "^VERSION\=" | cut -d'=' -f 2 | xargs)
}
read_os


case $os_release in
    ubuntu)
        apt update
        DEBIAN_FRONTEND=noninteractive apt install -y python3-pip python3-venv
        ;;
    almalinux)
        dnf install -y python3-pip
        ;;
    *)
        echo "ERROR: Unsupported OS: $os_release"
        exit 1
        ;;
esac

# Create or use the python venv oodenv environment
PYTHON_ENV_DIR="${THIS_DIR}/oodenv"
if [ ! -d "${PYTHON_ENV_DIR}" ]; then
    python3 -m venv "${PYTHON_ENV_DIR}"
fi
# activate environment
source "${PYTHON_ENV_DIR}/bin/activate"

# Install Ansible
printf "Installing Ansible\n"
python3 -m pip install -r ${THIS_DIR}/requirements.txt

# Install dependencies
printf "Installing dependencies\n"
ansible-playbook ${THIS_DIR}/dependencies.yml

printf "\n\n"
printf "Applications installed\n"
printf "===============================================================================\n"
columns="%-16s| %.10s\n"
printf "$columns" Application Version
printf -- "-------------------------------------------------------------------------------\n"
printf "$columns" Python `python3 --version | awk '{ print $2 }'`
printf "$columns" Ansible `ansible --version | head -n 1 | awk '{ print $3 }' | sed 's/]//'`
printf "$columns" yq `yq --version | awk '{ print $4 }'`
printf "===============================================================================\n"

yellow=$'\e[1;33m'
default=$'\e[0m'
printf "\n${yellow}Dependencies installed in a python environment${default}. To activate, run:\n"
printf "\nsource %s/bin/activate\n\n" "${PYTHON_ENV_DIR}"
