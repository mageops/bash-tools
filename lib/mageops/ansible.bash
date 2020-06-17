mageops::ansible::__module__() {
  lib::import mageops::core

  export ANSIBLE_FORCE_COLOR="yes"

  mageops::ansible::virtualenv::install() {
    true # Not implemented
  }

  mageops::ansible::virtualenv::activate() {
    true # Not implemented
  }

  mageops::ansible::virtualenv::update() {
    true # Not implemented
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