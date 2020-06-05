#!/usr/bin/env bash

set -euo pipefail

. lib/utils.sh
. lib/remote.sh
. lib/mysql.sh
. lib/filesystem.sh
. lib/magento.sh

if [ ! $# -eq 3 ] ; then
  echo "Usage: $0 <export|import> <all|{project}> <all|db|code|media>"
  exit 1
fi

MODE="$1"
PROJECTS="$2"
WHAT="$3"

LOCAL_ROOT="archive"
REMOTE_ROOT="${REMOTE_DIR:-/var/www/magento}"
TIMESTAMP="$(date +%Y-%m-%d)"

project-export-db() {
  linfo "Exporting project $(lq $PROJECT) db"
  magento-db-export "$PROJECT" "$LOCAL_PROJECT_DIR/db.sql.gz"
}

project-export-code() {
  linfo "Exporting project $(lq $PROJECT) code"
  magento-code-export "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/code.tar.gz"
}

project-export-media() {
  linfo "Exporting project $(lq $PROJECT) media"
  magento-media-export "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/media.tar.gz"
}

project-export-all() {
  project-export-db && project-export-media && project-export-code
}

project-import-db() {
  linfo "Importing project $(lq $PROJECT) db"
  magento-db-import "$PROJECT" "$PROJECT" "vagrant" "$LOCAL_PROJECT_DIR/db.sql.gz"
}

project-import-code() {
  linfo "Importing project $(lq $PROJECT) code"
  fs-unarchive "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/code.tar.gz"
}

project-import-media() {
  linfo "Importing project $(lq $PROJECT) media"
  fs-unarchive "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/media.tar.gz"
}

project-import-all() {
  project-import-db && project-import-media && project-import-code
}

project-list-export() {
  lstep "List remote projects" \
    `remote-cmd \
      find "$REMOTE_ROOT" -mindepth 1 -maxdepth 1 -type d -printf "%P\n"`
}

project-list-import() {
  lstep "List local projects" \
    find "$LOCAL_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%P\n'
}

if [ "$PROJECTS" == "all" ] ; then
  PROJECTS="$("project-list-$MODE")"
fi

for PROJECT in $PROJECTS ; do
  export LOCAL_PROJECT_DIR="$LOCAL_ROOT/$PROJECT"
  export REMOTE_PROJECT_DIR="$REMOTE_ROOT/$PROJECT"

  lstep "Create local project dir $(lq $LOCAL_PROJECT_DIR)" mkdir -p "$LOCAL_PROJECT_DIR"
  lstep "Create remote project dir $(lq $REMOTE_PROJECT_DIR)" `remote-cmd mkdir -p "$REMOTE_PROJECT_DIR"`
  
  linfo "Processing project $(lq $PROJECT)"

  if ! "project-$MODE-$WHAT" ; then
    lwarn "Failed to process project $(lq $PROJECT) but continuing"
  fi
done