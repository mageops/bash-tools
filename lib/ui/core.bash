ui::core::__module__() {
  [ -t 1 ]          && export UI_TTY_HAS=true         || export UI_TTY_HAS=false

  export MAGEOPS_UI_COLOR_ENABLED=true
  export MAGEOPS_UI_COLOR_FORCE="${MAGEOPS_UI_COLOR_FORCE:-false}"

  if ! $UI_TTY_HAS ; then
     $MAGEOPS_UI_COLOR_FORCE || export MAGEOPS_UI_COLOR_ENABLED=false
  fi

  export UI_CHR_DUMMY="$(printf '\xcf')"
  export UI_CHR_EXPANDER="${UI_CHR_EXPANDER:-.}"

  ui::cr() { echo -ne "\e[0K\r" ; }
}