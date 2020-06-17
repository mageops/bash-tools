mageops::core::__module__() {
  export MAGEOPS_PREFIX="${MAGEOPS_PREFIX:-/opt/mageops}"

  export MAGEOPS_ANSIBLE_ROOT_DIR="${MAGEOPS_PREFIX}/ansible"
  export MAGEOPS_ANSIBLE_VENV_DIR="${MAGEOPS_ANSIBLE_ROOT_DIR}/virtualenv"
  
  export MAGEOPS_ANSIBLE_REPO="https://github.com/mageops/ansible-infrastructure.git"
  export MAGEOPS_ANSIBLE_BRANCH="${MAGEOPS_ANSIBLE_BRANCH:-master}"
  export MAGEOPS_ANSIBLE_INVENTORY="${MAGEOPS_ANSIBLE_INVENTORY:-inventory/raccoon.yml}"

  export MAGEOPS_ANSIBLE_DIR="${MAGEOPS_ANSIBLE_ROOT_DIR}/infrastructure"
  export MAGEOPS_ANSIBLE_TMP_DIR="${MAGEOPS_ANSIBLE_DIR}/tmp"
  export MAGEOPS_ANSIBLE_VARS_DIR="${MAGEOPS_ANSIBLE_DIR}/vars"
  export MAGEOPS_ANSIBLE_VARS_PROJECT_DIR="${MAGEOPS_ANSIBLE_VARS_DIR}/project"
  export MAGEOPS_ANSIBLE_VARS_GLOBAL_DIR="${MAGEOPS_ANSIBLE_VARS_DIR}/global"
}