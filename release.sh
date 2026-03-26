#!/bin/bash
set -euo pipefail

if [[ "${1:-}" == "" || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $0 <release-tag>"
    exit 1
fi

release_tag="$1"

# Resolve script directory so project.ini lookup works from any cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_INI="${SCRIPT_DIR}/project.ini"

if [[ ! -f "${PROJECT_INI}" ]]; then
    echo "ERROR: Could not find ${PROJECT_INI}" >&2
    exit 1
fi

project_version="$(awk -F '=' '/^[[:space:]]*version[[:space:]]*=/ { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit }' "${PROJECT_INI}")"

if [[ "${project_version}" == "" ]]; then
    echo "ERROR: Could not parse version from ${PROJECT_INI}" >&2
    exit 1
fi

if [[ "${release_tag}" != "${project_version}" ]]; then
    echo "ERROR: release tag '${release_tag}' does not match project.ini version '${project_version}'" >&2
    exit 1
fi

echo "Validated: release tag '${release_tag}' matches project.ini version '${project_version}'."
