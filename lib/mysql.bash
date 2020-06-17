mysql::__module__() {
  MYSQL_USER="${MYSQL_USER:-root}"
  MYSQL_PASS="${MYSQL_PASS:-vagrant}"
  MYSQL_HOST="${MYSQL_HOST:-}"
  MYSQL_DUMP_OPTS="${MYSQL_DUMP_OPTS:-
    --quick
    --delayed-insert
    --flush-privileges
  }"

  mysql::args() {
    [ -z "$MYSQL_HOST" ] || echo \
      -h"$MYSQL_HOST"

    echo \
      -u"$MYSQL_USER" \
      -p"$MYSQL_PASS"
  }

  mysql::dump-args() {
    local MYSQL_DB="$1"; shift

    echo \
      "$MYSQL_DUMP_OPTS" \
      "$MYSQL_DB"

    for MYSQL_TABLE in ${MYSQL_DUMP_TABLES_SKIP_DATA:-} ; do 
      echo \
        --ignore-table-data="${MYSQL_DB}.${MYSQL_TABLE}" 
    done
  }

  mysql::list-dbs() {
    ui::step "<MySQL> List all databases" \
      `remote::cmd \
        mysql \
          $(mysql::args) \
          -sN -e 'SHOW DATABASES;'`
  }

  mysql::execute-db-query() {
    local MYSQL_DB="$1"; shift
    local MYSQL_QUERY="$1"; shift

    ui::step "<MySQL> Database $(ui::em $MYSQL_DB) query execute <- $(ui::em $MYSQL_QUERY)" \
      `remote::cmd \
        mysql \
          $(mysql::args) \
          "$MYSQL_DB" \
          -sN -e "$MYSQL_QUERY;"`
  }

  mysql::list-db-tables-like() {
    local MYSQL_DB="$1"; shift
    local MYSQL_TABLE_PATTERN="$1"; shift

    ui::step "<MySQL> Database $(ui::em $MYSQL_DB) <- list tables like $(ui::em $MYSQL_TABLE_PATTERN)" \
      `remote::cmd \
        mysql \
          $(mysql::args) \
          "$MYSQL_DB" \
          -sN -e "SHOW TABLES LIKE \"${MYSQL_TABLE_PATTERN}\";"`
  }

  mysql::create-db-dump() {
    local MYSQL_DB="$1"; shift
    local MYSQL_DB_DUMP_FILE="$1"; shift
    
    ui::step "<MySQL> Database $(ui::em $MYSQL_DB) dump -> $(ui::em $MYSQL_DB_DUMP_FILE)" \
      `remote::cmd \
        mysqldump \
          $(mysql::args) \
          $(mysql::dump-args "$MYSQL_DB")` \
      '|' sed -e "'s/DEFINER[ ]*=[ ]*[^*]*\*/\*/'" \
      '|' gzip \
      '>' "$MYSQL_DB_DUMP_FILE"

    ui::done "<MySQL> Database $(ui::em $MYSQL_DB) dump -> saved $(ui::em $(ui::fsize "$MYSQL_DB_DUMP_FILE")) file"
  }

  mysql::create-user() {
    local MYSQL_DB_USER="$1"; shift
    local MYSQL_DB_PASS="$1"; shift

    ui::step "<MySQL> User $(ui::em $MYSQL_DB_USER) <-> create if not exists" \
      `remote::cmd \
        mysql \
          $(mysql::args) \
            -sN -e "CREATE USER IF NOT EXISTS ${MYSQL_DB_USER_STRING} IDENTIFIED BY \"${MYSQL_DB_PASS}\""`
  }

  mysql::ensure-db-user() {
    local MYSQL_DB="$1"; shift
    local MYSQL_DB_USER="$1"; shift
    local MYSQL_DB_PASS="$1"; shift
    local MYSQL_DB_USER_STRING="\"${MYSQL_DB_USER}\"@\"%\""

    mysql::create-user "$MYSQL_DB_USER" "$MYSQL_DB_PASS"

    ui::step "<MySQL> Database $(ui::em $MYSQL_DB) <- grant all privileges to user $(ui::em $MYSQL_DB_USER)" \
      `remote::cmd \
        mysql \
          $(mysql::args) \
            -sN -e "GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO ${MYSQL_DB_USER_STRING}"`

    ui::step "<MySQL> Flush privileges" \
      `remote::cmd \
        mysql \
          $(mysql::args) \
            -sN -e "FLUSH PRIVILEGES"`
  }

  mysql::load-db-dump() {
    local MYSQL_DB="$1"; shift
    local MYSQL_DB_DUMP_FILE="$1"; shift

    ui::step "<MySQL> Database $(ui::em $MYSQL_DB) load <- $(ui::em $MYSQL_DB_DUMP_FILE)" \
      gzcat "$MYSQL_DB_DUMP_FILE" '|' `remote::cmd \
        mysql --batch \
          $(mysql::args) \
          "$MYSQL_DB"`

    ui::done "<MySQL> Database $(ui::em $MYSQL_DB) load <- loaded $(ui::em $(ui::fsize "$MYSQL_DB_DUMP_FILE")) file"
  }

  mysql::import-db-dump() {
    local MYSQL_DB="$1"; shift
    local MYSQL_DB_USER="$1"; shift
    local MYSQL_DB_PASS="$1"; shift
    local MYSQL_DB_DUMP_FILE="$1"; shift

    ui::step "<MySQL> Database $(ui::em $MYSQL_DB) <-> drop if exists" \
      `remote::cmd \
        mysql \
          $(mysql::args) \
          -sN -e "DROP DATABASE IF EXISTS ${MYSQL_DB}"`

    ui::step "<MySQL> Database $(ui::em $MYSQL_DB) <-> create" \
      `remote::cmd \
        mysql \
          $(mysql::args) \
          -sN -e "CREATE DATABASE ${MYSQL_DB}"`

    mysql::load-db-dump "$MYSQL_DB" "$MYSQL_DB_DUMP_FILE"
    mysql::ensure-db-user "$MYSQL_DB" "$MYSQL_DB_USER" "$MYSQL_DB_PASS"
  }
}


