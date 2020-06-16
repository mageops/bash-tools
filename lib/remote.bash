remote::__module__() {
  REMOTE_SSH_HOST="${REMOTE_SSH_HOST:-192.168.100.100}"
  REMOTE_SSH_USER="${REMOTE_SSH_USER:-magento}"
  REMOTE_SSH_PORT="${REMOTE_SSH_PORT:-22}"
  REMOTE_SSH_ARGS="${REMOTE_SSH_ARGS:-}"


  remote::ssh-args() {
    echo "${REMOTE_SSH_ARGS}" \
      -oStrictHostKeyChecking=no \
      -oUserKnownHostsFile=/dev/null \
      -p${REMOTE_SSH_PORT} \
        "${REMOTE_SSH_USER}@${REMOTE_SSH_HOST}"
  }

  remote::cmd() {
    echo ssh `remote::ssh-args` "'$(printf "%q " "$@")'"
  }

  remote::install-deps() {
    ui::step "Install PV for progress" \
      `remote::cmd 'which pv >/dev/null 2>/dev/null || yum -y install pv'`
  }
}
