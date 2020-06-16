#!/usr/bin/env bash

set -e

. "${MAGEOPS_BASH_LIB_DIR:-.}/lib/_lib.bash"

lib::import raccoon::migrate

raccoon::migrate::script "$@"

