ui::format::__module__() {
    lib::import ui::core

    ui::bold()       { echo -ne "\e[1m$*\e[0m" ; }
    ui::muted()      { echo -ne "\e[30m$*\e[0m" ; }
    ui::em()         { echo -ne "\e[36m$*\e[0m" ; }

    ui::value()      { echo -ne "\e[1;36m$*\e[0m" ; }
    ui::label()      { echo -ne "\e[35m$*\e[0m" ; }
    
    ui::fsize()      { ls -sh1 "$*" | cut -d' ' -f1; }

    ui::param() {
        local LABEL="$(echo $1)"
        local VALUE="$(echo $2)"
        local COMMENT="$(echo ${3:-})"
        local WIDTH="${4:-40}"
        local NWIDTH="$(echo -n "$LABEL" | wc -c)"
        local VPAD="$(( $WIDTH - $NWIDTH ))"

        printf "%s${UI_CHR_DUMMY}$(ui::muted "%${VPAD}s")${UI_CHR_DUMMY}%s" \
          "$(echo "$(ui::label "$LABEL")" | tr ' ' "$UI_CHR_DUMMY")" \
          " " \
          "$(echo "$(ui::value "$VALUE")" | tr ' ' "$UI_CHR_DUMMY")" \
          | tr " $UI_CHR_DUMMY" "$UI_CHR_EXPANDER "
            

        [ -z "$COMMENT" ] || echo -n " $(ui::muted "($COMMENT)")"
        echo 
    }

    function ui::prefix() {
        local PREFIX=${1:-}
        sed -e 's/^/'"$PREFIX"'/g'
    }

    function ui::prefix:cmd() {
        local PREFIX=${1:- }; shift
        $@ | ui::prefixed "$PREFIX"
    }

    function ui::indent:cmd() {
        ui::cmd-prefixed ' ' $@
    }
}
