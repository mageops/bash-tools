raccoon::module() {
  # The credentials of the user that **Magento** uses to access the DB
  RACCOON_PROJECT_DB_USER="${RACCOON_PROJECT_DB_USER:-vagrant}"
  RACCOON_PROJECT_DB_PASS="${RACCOON_PROJECT_DB_PASS:-vagrant}"

  lib::import raccoon::migrate
}