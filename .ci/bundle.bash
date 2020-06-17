#!/usr/bin/env bash

. "${MAGEOPS_BASH_LIB_DIR:-.}/lib/_lib.bash"

lib::import ui


LIB="$MAGEOPS_BASH_LIB_DIR"
OUT="__bundle__"


bundle-library() {
  cat > "$OUT/lib._bundle_.bash" <<ENDBANNER
#########
#
#    MageOps Bash Tools Library Bundle
# 
#    On: $(date)
#    By: $(whoami) @ $(hostname)
#    Machine: $(uname -a)
#
#    Recent repository activity:
#
$(git log --pretty=oneline --abbrev-commit --decorate=full -5 | sed 's/^/#        /g')
#
#########
ENDBANNER

  find "$LIB/" -type f -iname '*.bash' | while read LIBMODULE ; do
    echo -e "\n\n####### BEGIN Library Module: $LIBMODULE #######\n" >> "$OUT/lib._bundle_.bash"
    cat "$LIBMODULE" >> "$OUT/lib._bundle_.bash" | head -1
    echo -e "\n####### END Library Module: $LIBMODULE #######" >> "$OUT/lib._bundle_.bash"
  done
}

bundle-script() {
  SCRIPT="$1"
  OUTFILE="$2"
  OUTFILE="${OUTFILE%.bash}._bundle_.bash"

  cat > "$OUTFILE" <<ENDBANNER
#!/usr/bin/env bash

#########
#
#    [Script Bundle] Source file: $(realpath "$1")
#
#########
ENDBANNER

  cat "$OUT/lib._bundle_.bash" | tail -n+2 >> "$OUTFILE"

ENDBANNER

  echo -e "\n\n####### BEGIN Script: $1 #######\n" >> "$OUTFILE"
  cat "$1" | sed -E 's~^( *(source|\.).*lib/_lib\.bash['\''" ]*)$~# Library bundled, removed import: \1 ~g' >> "$OUTFILE"
  echo -e "\n\n####### END Script: $1#######\n" >> "$OUTFILE"
}

ui::step "Clean $(ui::em $OUT)" \
  rm -rf "$OUT" '&&' mkdir -p "$OUT"

ui::step "Bundle library files to $(ui::em $OUT/lib._bundle_.bash)" \
  bundle-library

find bin -type f -iname '*.bash' | while read SCRIPT ; do
  OUTFILE="$OUT/$(echo "$SCRIPT" | tr '/' '.')"
  mkdir -p "$(dirname "$OUTFILE")"

  ui::step "Bundle $(ui::em $SCRIPT) with lib" \
    bundle-script "$SCRIPT" "$OUTFILE"
done

