mageops::guest::__module__() {
  lib::import ui
  lib::import mageops::core
  lib::import mageops::ansible
  lib::import mageops::bootstrap

  mageops::guest::trim() {
    ui::info "Initial root filesystem size: $(ui::em $(du -sh / 2>/dev/null | cut -d"$(printf '\t')" -f1))"

    ui::step "Clean YUM cache" \
      yum -y clean all '||' true

    ui::step "Clean DNF cache" \
      dnf -y clean all '||' true

    ui::step "Stop services" \
      '&&' systemctl stop php-fpm \
      '&&' systemctl stop varnish \
      '&&' systemctl stop elasticsearch \
      '&&' systemctl stop nginx \
      '&&' systemctl stop mysql \
      '&&' systemctl stop redis \
      '&&' systemctl stop redis-sessions \
      '&&' systemctl stop elasticsearch

    ui::step "Remove unneeded cache and service data files" \
      rm -rvf \
          /{root,home/magento}/{.cache/*,.opcache/*,.*history,.composer,.yarn/*,.npm/*} \
          /var/lib/mysql/ib_logfile* \
          /var/lib/mysql/ib_tmp* \
          /var/lib/varnish/* \
          /var/lib/redis/* \
          /var/lib/redis-sessions/*

    ui::step "Trim system logs" \
      echo '|' find /var/log -type f -exec tee {} \;
    
    ui::step "Trim Magento logs" \
      echo '|' find /var/www/magento/ -mindepth 3 -type f -path '*/var/log/*' -exec tee {} \;

    ui::info "Trimmed root filesystem size: $(ui::em $(du -sh / 2>/dev/null | cut -d"$(printf '\t')" -f1))"
  }
}