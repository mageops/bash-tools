FS_EXCLUDE_PATTERNS=""

fs-archive-tar-args() {
  for EXCLUDE_PATTERN in ${FS_EXCLUDE_PATTERNS} ; do 
    echo \
      --exclude "$EXCLUDE_PATTERN"
  done
}

fs-archive-dir() {
    local FS_ROOT_DIR="$1"; shift 
    local FS_SRC_DIR="$1"; shift
    local FS_ARCHIVE_PATH="$1"; shift

    # Warning! This argument order is for GNU tar 1.26 (CentOS 7)
    # - different order of exclude arguments might be needed with
    # later versions!
    lstep "<Filesystem> Archive $(lq $FS_ROOT_DIR/$FS_SRC_DIR) -> $(lq $FS_ARCHIVE_PATH)" \
      `remote-cmd \
        tar \
          -cz \
          -C "$FS_ROOT_DIR" \
          $(fs-archive-tar-args) \
            "$FS_SRC_DIR"` \
      '>' "$FS_ARCHIVE_PATH"

    ldone "<Filesystem> Archive $(lq $FS_ROOT_DIR/$FS_SRC_DIR) -> written $(lq $(lfsize "$FS_ARCHIVE_PATH")) file"
}

fs-unarchive() {
    local FS_ROOT_DIR="$1"; shift 
    local FS_ARCHIVE_PATH="$1"; shift

    lstep "<Filesystem> Ensure root $(lq $FS_ROOT_DIR) dir exists" \
      `remote-cmd \
        mkdir -p "$FS_ROOT_DIR"`

    lstep "<Filesystem> Unarchive $(lq $FS_ARCHIVE_PATH) -> $(lq $FS_ROOT_DIR)" \
      gzcat "$FS_ARCHIVE_PATH" \
      '|' `remote-cmd \
        tar \
          -x \
          -C "$FS_ROOT_DIR"`

    ldone "<Filesystem> Archive $(lq $FS_ARCHIVE_PATH) -> extracted $(lq $(lfsize "$FS_ARCHIVE_PATH")) file"
}

