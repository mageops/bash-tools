#!/usr/bin/env bash

. lib/utils.sh

ENTRYPOINTS="$(ls -1 *.sh)"
LIBS="$(ls -1 lib/*.sh)"

BUILD_DIR="bin"

bundle() {
  local ENTRYPOINT="$1"

  for LIB in $LIBS ; do 
    LIBRE="$(echo $LIB | sed 's~\([/.]\)~\\\1~g')"

    sed -i -e '/\. '"$LIBRE"'/{
      s~\. '"$LIBRE"'~###### Bundled lib -> '"$LIB"' ######~g
      r '"$LIB"'
    }' "$ENTRYPOINT"
  done
}

ui::step "Clean $(ui::q $BUILD_DIR)" \
  rm -rf "$BUILD_DIR" '&&' mkdir -p "$BUILD_DIR"

for ENTRYPOINT in $ENTRYPOINTS ; do
  ui::step "Copy $(ui::q $ENTRYPOINT) to $(ui::q $BUILD_DIR)" \
    cp -f "$ENTRYPOINT" "$BUILD_DIR"

  ui::step "Bundle $(ui::q $BUILD_DIR/$ENTRYPOINT) with libs" \
    bundle "$BUILD_DIR/$ENTRYPOINT"
done

