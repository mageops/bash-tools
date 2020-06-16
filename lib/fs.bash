FS_EXCLUDE_PATTERNS=""

fs::__module__() {
  fs::archive-tar-args() {
    for EXCLUDE_PATTERN in ${FS_EXCLUDE_PATTERNS} ; do 
      echo \
        --exclude "$EXCLUDE_PATTERN"
    done
  }

  fs::archive-dir() {
      local FS_ROOT_DIR="$1"; shift 
      local FS_SRC_DIR="$1"; shift
      local FS_ARCHIVE_PATH="$1"; shift

      # Warning! This argument order is for GNU tar 1.26 (CentOS 7)
      # - different order of exclude arguments might be needed with
      # later versions!
      ui::step "<Filesystem> Archive $(ui::q $FS_ROOT_DIR/$FS_SRC_DIR) -> $(ui::q $FS_ARCHIVE_PATH)" \
        `remote::cmd \
          tar \
            -cz \
            -C "$FS_ROOT_DIR" \
            $(fs::archive-tar-args) \
              "$FS_SRC_DIR"` \
        '>' "$FS_ARCHIVE_PATH"

      ui::done "<Filesystem> Archive $(ui::q $FS_ROOT_DIR/$FS_SRC_DIR) -> written $(ui::q $(ui::fsize "$FS_ARCHIVE_PATH")) file"
  }

  fs::unarchive() {
      local FS_ROOT_DIR="$1"; shift 
      local FS_ARCHIVE_PATH="$1"; shift

      ui::step "<Filesystem> Ensure root $(ui::q $FS_ROOT_DIR) dir exists" \
        `remote::cmd \
          mkdir -p "$FS_ROOT_DIR"`

      ui::step "<Filesystem> Unarchive $(ui::q $FS_ARCHIVE_PATH) -> $(ui::q $FS_ROOT_DIR)" \
        gzcat "$FS_ARCHIVE_PATH" \
        '|' `remote::cmd \
          tar \
            -x \
            -C "$FS_ROOT_DIR"`

      ui::done "<Filesystem> Archive $(ui::q $FS_ARCHIVE_PATH) -> extracted $(ui::q $(ui::fsize "$FS_ARCHIVE_PATH")) file"
  }
}
