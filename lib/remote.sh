SSH_HOST="${SSH_HOST:-192.168.100.100}"
SSH_USER="${SSH_USER:-magento}"

remote-ssh-args() {
  echo \
    -oStrictHostKeyChecking=no \
    -oUserKnownHostsFile=/dev/null \
      "${SSH_USER}@${SSH_HOST}"
}

remote-cmd() {
  echo ssh `remote-ssh-args` "'$(printf "%q " "$@")'"
}

remote-install-deps() {
  lstep "Install PV for progress" \
    `remote-cmd 'which pv >/dev/null 2>/dev/null || yum -y install pv'`
}
