#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${THIS_DIR}/oodenv/bin/activate oodenv

exec /bin/env python3 "$@"
