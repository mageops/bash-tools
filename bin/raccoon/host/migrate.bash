#!/usr/bin/env bash

set -e

source "${MAGEOPS_BASH_LIB_DIR:-.}/lib/_lib.bash"

lib::import raccoon::host

raccoon::host::migrate::script "$@"

