mageops::ansible::__module__() {
  lib::import mageops::core

  export ANSIBLE_FORCE_COLOR="yes"

  mageops::ansible::virtualenv::install() {
  }

  mageops::ansible::virtualenv::activate() {
  }

  mageops::ansible::virtualenv::update() {
  }

  mageops::ansible::playbook() {
    local PLAYBOOK="$1"; shift

    mageops::ansible::virtualenv::activate

    pushd "$MAGEOPS_ANSIBLE_DIR"

    ansible-playbook \
        -i inventory/raccoon.yml \
        --limit raccoon_local \
            "$@" \
            "${PLAYBOOK}.yml"

    popd
  }
}