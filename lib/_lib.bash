#!/usr/bin/env bash

#########
#
#    *** MageOps Bash Tools Library ***
#
#    Homepage: https://github.com/mageops/bash-tools
#
#    2020 (c) creativestyle Polska Sp. z o.o. <hello@creativestyle.pl>
#    2020 (c) Filip Sobalski <pinkeen@gmail.com>
# 
#########

set -euo pipefail

export MAGEOPS_LEAVING=""
export MAGEOPS_DEBUG="${MAGEOPS_DEBUG:-false}"
export MAGEOPS_CLEANUP_HOOKS=()

trap 'EXIT_CODE=$? ; lib::trap $EXIT_CODE || true ; exit $EXIT_CODE' EXIT HUP QUIT INT

lib::join() {
  local SEP="${1:-:}"; shift
  printf "%s:" "$@" | sed -E 's~^['"$SEP"' ]*|['"$SEP"' ] *$~~g'
}

lib::split() {
  local SEP="${1:-:}"; shift
  while IFS="$SEP" read -ra ITEMS; do
      for ITEM in "${ITEMS[@]}"; do
          echo "$ITEM"
      done
  done <<< "$*"
}

lib::path::get() {
  local PWD="$(pwd)"
  local SWD="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  local MAGEOPS_BASH_LIB_SEARCH_PATHS=("${MAGEOPS_BASH_LIB_DIR:-}")
  MAGEOPS_BASH_LIB_SEARCH_PATHS+=("$@")
  MAGEOPS_BASH_LIB_SEARCH_PATHS+=(
    "$PWD"
    "$PWD/lib"
    "$SWD"
    "$SWD/lib"
    "$HOME/.local/share/mageops/bash/lib"
    "$HOME/.mageops/bash/lib"
    "/usr/share/mageops/bash/lib"
    "/usr/local/share/mageops/bash/lib"
    "/opt/mageops/bash/lib"
  )

  lib::join ":" "${MAGEOPS_BASH_LIB_SEARCH_PATHS[@]}"
}

lib::path::locate() {
  local FILE_NAME="${1:-_lib.bash}"
  local SEARCH_PATH="${2:-${MAGEOPS_BASH_LIB_SEARCH_PATH:-}}"

  while read -ra TRY_PATH ; do
    if [ -z "$TRY_PATH" ] ; then
      continue
    elif [ -f "$TRY_PATH/$FILE_NAME" ] ; then
      echo "$TRY_PATH"
      return
    fi
  done <<< "$(lib::split ':' "$SEARCH_PATH")"  
}

export MAGEOPS_BASH_LIB_SEARCH_PATH="${MAGEOPS_BASH_LIB_SEARCH_PATH:-$(lib::path::get)}"
export MAGEOPS_BASH_LIB_DIR="${MAGEOPS_BASH_LIB_DIR:-$(lib::path::locate)}"

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
    if declare -F "$MODULE::__module__" &>/dev/null; then
      "$MODULE::__module__"
    else
      if [ -z "${MAGEOPS_BASH_LIB_DIR:-}" ]; then
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

