raccoon::migrate::__module__() {
  lib::import ui
  lib::import fs
  lib::import remote
  lib::import magento
  lib::import mysql
  lib::import timestamp

  RACCOON_MIGRATE_LOCAL_ARCHIVE_DIR="${RACCOON_MIGRATE_LOCAL_ARCHIVE_DIR:-archive}"
  RACCOON_MIGRATE_REMOTE_ROOT_DIR="${RACCOON_MIGRATE_RACCOON_MIGRATE_REMOTE_ROOT_DIR_DIR:-/var/www/magento}"
  RACCOON_MIGRATE_TIMESTAMP="$(timestamp::day)"

  raccoon::migrate::export-db() {
    ui::info "Exporting project $(ui::q $PROJECT) db"
    magento::db::export "$PROJECT" "$LOCAL_PROJECT_DIR/db.sql.gz"
  }

  raccoon::migrate::export-code() {
    ui::info "Exporting project $(ui::q $PROJECT) code"
    magento::code::export "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/code.tar.gz"
  }

  raccoon::migrate::export-media() {
    ui::info "Exporting project $(ui::q $PROJECT) media"
    magento::media::export "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/media.tar.gz"
  }

  raccoon::migrate::export-all() {
    raccoon::migrate::export-db && raccoon::migrate::export-media && raccoon::migrate::export-code
  }

  raccoon::migrate::import-db() {
    ui::info "Importing project $(ui::q $PROJECT) db"
    magento::db::import "$PROJECT" "$RACCOON_PROJECT_DB_USER" "$RACCOON_PROJECT_DB_PASS" "$LOCAL_PROJECT_DIR/db.sql.gz"
  }

  raccoon::migrate::import-code() {
    ui::info "Importing project $(ui::q $PROJECT) code"
    fs::unarchive "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/code.tar.gz"
  }

  raccoon::migrate::import-media() {
    ui::info "Importing project $(ui::q $PROJECT) media"
    fs::unarchive "$REMOTE_PROJECT_DIR" "$LOCAL_PROJECT_DIR/media.tar.gz"
  }

  raccoon::migrate::import-all() {
    raccoon::migrate::import-db && raccoon::migrate::import-media && raccoon::migrate::import-code
  }

  raccoon::migrate::list-export() {
    ui::step "List remote projects" \
      `remote::cmd \
        find "$RACCOON_MIGRATE_REMOTE_ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%P\n"`
  }

  raccoon::migrate::list-import() {
    ui::step "List local projects" \
      find "$RACCOON_MIGRATE_LOCAL_ARCHIVE_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%P\n'
  }

  raccoon::migrate::script() {
      if [ ! $# -eq 3 ] ; then
        echo "Usage: $0 <export|import> <all|{project}> <all|db|code|media>"
        lib::leave 1
      fi

      local MODE="$1"
      local PROJECTS="$2"
      local WHAT="$3"


      if [ "$PROJECTS" == "all" ] ; then
        PROJECTS="$("raccoon::migrate::list-$MODE")"
      fi

      for PROJECT in $PROJECTS ; do
        local LOCAL_PROJECT_DIR="$RACCOON_MIGRATE_LOCAL_ARCHIVE_DIR/$PROJECT"
        local REMOTE_PROJECT_DIR="$RACCOON_MIGRATE_REMOTE_ROOT_DIR/$PROJECT"

        ui::step "Create local project dir $(ui::q $LOCAL_PROJECT_DIR)" mkdir -p "$LOCAL_PROJECT_DIR"
        ui::step "Create remote project dir $(ui::q $REMOTE_PROJECT_DIR)" `remote::cmd mkdir -p "$REMOTE_PROJECT_DIR"`
        
        ui::info "Processing project $(ui::q $PROJECT)"

        if ! "raccoon::migrate::$MODE-$WHAT" ; then
          ui::warn "Failed to process project $(ui::q $PROJECT) but continuing"
        fi
      done
  }
}