set -euo pipefail

# Queries to execute prior to running the dump
MAGENTO_DB_DUMP_QUERY_CLEANUP_QUOTES="DELETE FROM quote WHERE customer_id IS NULL"

# Tables which will be completely omitted from the dump
MAGENTO_DB_DUMP_TABLES_IGNORE=""

# Tables for which data will not be dumped only schema
MAGENTO_DB_DUMP_TABLES_SKIP_DATA="
  admin_system_messages
  admin_user_session
  adminnotification_inbox
  authorization_role
  authorization_rule
  cache_tag
  cache_warmup_queue
  cache_warmup_queue_debug_events
  cron_schedule
  customer_log
  customer_visitor
  indexer_state
  integration
  magento_acknowledged_bulk
  magento_banner_customersegment
  magento_bulk
  magento_catalogpermissions_index_replica
  magento_operations
  session
  varnish_cache_cleanup_queue
  varnish_cache_relations
  varnish_cache_tags
  varnish_cache_url_tags
"

MAGENTO_CODE_DUMP_EXCLUDE_PATTERNS="
  ./var
  ./pub/media
"

MAGENTO_MEDIA_DUMP_EXCLUDE_PATTERNS="
  pub/media/tmp
  pub/media/cache
  pub/media/.thumbs
  pub/media/.thumbs*
  pub/media/thumbnails
  pub/media/catalog/tmp
  pub/media/catalog/cache
  pub/media/catalog/.thumbs
  pub/media/catalog/thumbnails
  pub/media/catalog/product/tmp
  pub/media/catalog/product/cache
  pub/media/catalog/product/.thumbs
  pub/media/catalog/product/thumbnails
  pub/media/catalog/category/tmp
  pub/media/catalog/category/cache
  pub/media/catalog/category/.thumbs
  pub/media/catalog/category/thumbnails
"

magento-db-export() {
  local MAGENTO_DB="$1"; shift
  local MAGENTO_DB_DUMP_FILE="$1"; shift

  export MYSQL_DUMP_TABLES_SKIP_DATA="
    $MAGENTO_DB_DUMP_TABLES_SKIP_DATA 
    $(mysql-list-db-tables-like "$MAGENTO_DB" "%_tmp")
    $(mysql-list-db-tables-like "$MAGENTO_DB" "%_replica")
  "

  mysql-execute-db-query "$MAGENTO_DB" "$MAGENTO_DB_DUMP_QUERY_CLEANUP_QUOTES"
  mysql-create-db-dump "$MAGENTO_DB" "$MAGENTO_DB_DUMP_FILE" 
}

magento-db-import() {
  local MAGENTO_DB="$1"; shift
  local MAGENTO_DB_USER="$1"; shift
  local MAGENTO_DB_PASS="$1"; shift
  local MAGENTO_DB_DUMP_FILE="$1"; shift

  mysql-import-db-dump "$MAGENTO_DB" "$MAGENTO_DB_USER" "$MAGENTO_DB_PASS" "$MAGENTO_DB_DUMP_FILE"
}

magento-code-export() {
  local MAGENTO_DIR="$1"; shift 
  local MAGENTO_CODE_ARCHIVE_FILE="$1"; shift

  export FS_EXCLUDE_PATTERNS="$MAGENTO_CODE_DUMP_EXCLUDE_PATTERNS"

  fs-archive-dir "$MAGENTO_DIR" "." "$MAGENTO_CODE_ARCHIVE_FILE"
}

magento-media-export() {
  local MAGENTO_DIR="$1"; shift 
  local MAGENTO_MEDIA_ARCHIVE_FILE="$1"; shift

  export FS_EXCLUDE_PATTERNS="$MAGENTO_MEDIA_DUMP_EXCLUDE_PATTERNS"

  fs-archive-dir "$MAGENTO_DIR" "pub/media" "$MAGENTO_MEDIA_ARCHIVE_FILE"
}

