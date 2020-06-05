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

lstep "Clean $(lq $BUILD_DIR)" \
  rm -rf "$BUILD_DIR" '&&' mkdir -p "$BUILD_DIR"

for ENTRYPOINT in $ENTRYPOINTS ; do
  lstep "Copy $(lq $ENTRYPOINT) to $(lq $BUILD_DIR)" \
    cp -f "$ENTRYPOINT" "$BUILD_DIR"

  lstep "Bundle $(lq $BUILD_DIR/$ENTRYPOINT) with libs" \
    bundle "$BUILD_DIR/$ENTRYPOINT"
done

