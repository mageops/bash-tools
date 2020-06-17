raccoon::host::migrate::__module__() {
  lib::import ui
  lib::import fs
  lib::import remote
  lib::import magento
  lib::import mysql
  lib::import timestamp

  RACCOON_MIGRATE_LOCAL_ARCHIVE_DIR="${RACCOON_MIGRATE_LOCAL_ARCHIVE_DIR:-archive}"
  RACCOON_MIGRATE_REMOTE_ROOT_DIR="${RACCOON_MIGRATE_RACCOON_MIGRATE_REMOTE_ROOT_DIR_DIR:-/var/www/magento}"
  RACCOON_MIGRATE_TIMESTAMP="$(timestamp::day)"

  raccoon::host::migrate::export-db() {
    ui::info "Exporting project $(ui::em $PROJECT) db"
    magento::db::export "$PROJECT" "$LOCAL_PROJECT_DIR/db.sql.gz"
  }

  raccoon::host::migrate::export-code() {
    ui::info "Exporting project $(ui::em $PROJECT) code"
    magento::code::export "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/code.tar.gz"
  }

  raccoon::host::migrate::export-media() {
    ui::info "Exporting project $(ui::em $PROJECT) media"
    magento::media::export "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/media.tar.gz"
  }

  raccoon::host::migrate::export-all() {
    raccoon::host::migrate::export-db && raccoon::host::migrate::export-media && raccoon::host::migrate::export-code
  }

  raccoon::host::migrate::import-db() {
    ui::info "Importing project $(ui::em $PROJECT) db"
    magento::db::import "$PROJECT" "$RACCOON_PROJECT_DB_USER" "$RACCOON_PROJECT_DB_PASS" "$LOCAL_PROJECT_DIR/db.sql.gz"
  }

  raccoon::host::migrate::import-code() {
    ui::info "Importing project $(ui::em $PROJECT) code"
    fs::unarchive "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/code.tar.gz"
  }

  raccoon::host::migrate::import-media() {
    ui::info "Importing project $(ui::em $PROJECT) media"
    fs::unarchive "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/media.tar.gz"
  }

  raccoon::host::migrate::import-all() {
    raccoon::host::migrate::import-db && raccoon::host::migrate::import-media && raccoon::host::migrate::import-code
  }

  raccoon::host::migrate::list-export() {
    ui::step "List remote projects" \
      `remote::cmd \
        find "$RACCOON_MIGRATE_REMOTE_ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%P\n"`
  }

  raccoon::host::migrate::list-import() {
    ui::step "List local projects" \
      find "$RACCOON_MIGRATE_LOCAL_ARCHIVE_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%P\n'
  }

  raccoon::host::migrate::script() {
      if [ ! $# -eq 3 ] ; then
        echo "Usage: $0 <export|import> <all|{project}> <all|db|code|media>"
        lib::leave 1
      fi

      local MODE="$1"
      local PROJECTS="$2"
      local WHAT="$3"


      if [ "$PROJECTS" == "all" ] ; then
        PROJECTS="$("raccoon::host::migrate::list-$MODE")"
      fi

      for PROJECT in $PROJECTS ; do
        local LOCAL_PROJECT_DIR="$RACCOON_MIGRATE_LOCAL_ARCHIVE_DIR/$PROJECT"
        local REMOTE_PROJECT_DIR="$RACCOON_MIGRATE_REMOTE_ROOT_DIR/$PROJECT"

        ui::step "Create local project dir $(ui::em $LOCAL_PROJECT_DIR)" mkdir -p "$LOCAL_PROJECT_DIR"
        ui::step "Create remote project dir $(ui::em $REMOTE_PROJECT_DIR)" `remote::cmd mkdir -p "$REMOTE_PROJECT_DIR"`
        
        ui::info "Processing project $(ui::em $PROJECT)"

        if ! "raccoon::host::migrate::$MODE-$WHAT" ; then
          ui::warn "Failed to process project $(ui::em $PROJECT) but continuing"
        fi
      done
  }
}