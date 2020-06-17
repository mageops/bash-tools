#!/usr/bin/env bash

. "${MAGEOPS_BASH_LIB_DIR:-.}/lib/_lib.bash"

lib::import ui


LIB="$MAGEOPS_BASH_LIB_DIR"
OUT="bin"

bundle-library() {
  cat > "$OUT/lib.bundle.bash" <<ENDBANNER
#!/usr/bin/env bash

#######
# MageOps Bash Tools Library Bundle
# On: $(date)
# By: $(whoami) @ $(hostname)
# Machine: $(uname -a)
#######
ENDBANNER

  find "$LIB/" -type f -iname '*.bash' | while read LIBMODULE ; do
    echo -e "\n\n####### BEGIN Library Module: $LIBMODULE #######\n" >> "$OUT/lib.bundle.bash"
    cat "$LIBMODULE" >> "$OUT/lib.bundle.bash"
    echo -e "\n####### END Library Module: $LIBMODULE #######" >> "$OUT/lib.bundle.bash"
  done
}

bundle-script() {
  NAME="${SCRIPT%.bash}"
  OUTFILE="$OUT/$NAME.bundle.bash"

  cat > "$OUTFILE" <<ENDBANNER
#!/usr/bin/env bash

#######
# Bundled Bash Tools Script: $(realpath "$1")
# On: $(date)
# By: $(whoami) @ $(hostname)
# Machine: $(uname -a)
#######

ENDBANNER

  cat "$OUT/lib.bundle.bash" >> "$OUTFILE"

ENDBANNER

  echo -e "\n\n####### BEGIN Script: $1 #######\n" >> "$OUTFILE"
  cat "$1" | sed -E 's~^( *(source|\.).*lib/_lib\.bash['\''" ]*)$~# Library bundled, removed import: \1 ~g' >> "$OUTFILE"
  echo -e "\n\n####### END Script: $1#######\n" >> "$OUTFILE"
}

ui::step "Clean $(ui::em $OUT)" \
  rm -rf "$OUT" '&&' mkdir -p "$OUT"

ui::step "Bundle library files to $(ui::em $OUT/lib.bundle.bash)" \
  bundle-library

 find . -maxdepth 1 -type f -iname '*.bash' | while read SCRIPT ; do
  ui::step "Bundle $(ui::em $SCRIPT) with lib" \
    bundle-script "$SCRIPT" "$OUT/$SCRIPT"
done

