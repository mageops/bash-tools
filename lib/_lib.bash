#!/usr/bin/env bash

set -euo pipefail

if [ -z "${MAGEOPS_BASH_LIB_DIR:-}" ] ; then 
  if [ -f "$(dirname "${BASH_SOURCE[0]}")/lib/_lib.bash" ] ; then 
    export MAGEOPS_BASH_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/lib"
  elif [ -f "$(pwd)/lib/_lib.bash" ] ; then
    export MAGEOPS_BASH_LIB_DIR="$(pwd)/lib"
  else
    export MAGEOPS_BASH_LIB_DIR=false
  fi
fi

export MAGEOPS_LEAVING=""
export MAGEOPS_DEBUG="${MAGEOPS_DEBUG:-false}"
export MAGEOPS_CLEANUP_HOOKS=()

trap 'EXIT_CODE=$?; lib::trap $EXIT_CODE; exit $EXIT_CODE' EXIT HUP QUIT INT

lib::leave() {
  local LEAVE_CODE="${1:-}"; shift
  local LEAVE_MESSAGE="${*}"

  export MAGEOPS_LEAVING="leaving willfully"
  [ -z "$LEAVE_MESSAGE" ] || "[$LEAVE_CODE] Leaving: $LEAVE_MESSAGE"

  exit $LEAVE_CODE
}

lib::emerg() {
  local ERROR_CODE="${1:-}"
  echo -e "\nEmergency exit error code: $ERROR_CODE" >&2
  exit $ERROR_CODE
}

lib::trap() {
  local EXIT_CODE="$1"

  lib::cleanup
  
  [ $EXIT_CODE -eq 0 ] && return 
  [ -z "${MAGEOPS_LEAVING:-}" ] && lib::emerg
}

lib::jobs::kill() {
  kill -9 `jobs -p` &>/dev/null || true
}

lib::cleanup() { 
  for HOOK in "${MAGEOPS_CLEANUP_HOOKS[@]}"; do
    ${HOOK} || echo "Warning! Cleanup hook failed: $HOOK"
  done

  lib::jobs::kill
}

lib::cleanup::hook() {
  MAGEOPS_CLEANUP_HOOKS+=("${*}")
}

lib::import() {
  local MODULE="$1"
  
  if ! declare -F "$MODULE::__imported__" &>/dev/null ; then
    if declare -F "$MODULE::__module__" ; then
      "$MODULE::__module__"
    else
      if [ "${MAGEOPS_BASH_LIB_DIR:-}" == "false" ]; then
        echo "Cannot locate module $MODULE: environment variable MAGEOPS_BASH_LIB_DIR is not set" >&2
        exit 99
      fi

      local MODULE_FILE="$(echo $MODULE | sed 's~::~/~g').bash"
      local MODULE_PATH="$MAGEOPS_BASH_LIB_DIR/$MODULE_FILE"

      if [ ! -f "$MODULE_PATH" ] ; then
        echo "Cannot locate module $MODULE: file $MODULE_PATH not found" >&2
        exit 99
      fi

      source "$MODULE_PATH"

      if declare -F "$MODULE::__module__" &>/dev/null ; then
        "$MODULE::__module__"
      else
        echo "Cannot locate module $MODULE: function $MODULE::__module__ is not defined in file $MODULE_PATH" >&2
        exit 99
      fi
    fi

    eval "$MODULE::__imported__() { echo 'Module $MODULE is imported'; }"
  fi
}

