ui::task::__module__() {
    export MAGEOPS_UI_SPINJOBS=""
    export MAGEOPS_DEBUG="${MAGEOPS_DEBUG:-false}"

    lib::cleanup::hook ui::cleanup

    ui::cleanup() {
        tput cnorm
        kill $MAGEOPS_UI_SPINJOBS &>/dev/null || true
    }

    ui::ok()        { echo -e  "[\e[1;32m  OK  \e[0m] $@" ; }
    ui::info()      { echo -e  "[\e[1;34m INFO \e[0m] $@" ; }
    ui::task()      { echo -e  "[\e[1;36m STEP \e[0m] \n\n  ----------  \e[1;36m$@\e[0m  ----------  \n" ; }
    ui::warn()      { echo -e  "[\e[1;33m WARN \e[0m] $@" >&2 ; }
    ui::fail()      { echo -e  "[\e[1;31mFAILED\e[0m] $@" >&2 ; }
    ui::crit()      { echo -e  "[\e[1;35m CRIT \e[0m] $@" >&2 ; }
    ui::done()      { echo -e  "[\e[1;32m DONE \e[0m] $@" ; }
    ui::debug()     { ! $MAGEOPS_DEBUG || echo -e  "[\e[2m DBUG \e[0m] $@" >&2 ; }

    ui::q()         { echo -ne "\e[36m$@\e[0m" ; }
    ui::overw()     { echo -ne "\e[0K\r" ; }
    ui::cmd()       { ui::debugcmd "$@"; "$@"; }
    ui::qcmd()      { while (( $# > 0 )) ; do echo -ne "'$1' "; shift; done; }
    ui::debugcmd()  { ui::debug "Cmd: $(ui::q $(echo "$@"))" ; }
    ui::fsize()     { ls -sh1 "$@" | cut -d' ' -f1; }

    ui::spin() {
        local DELAY=0.08s
        while true ; do
            echo -ne "[\e[1;36m|-----\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m-|----\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m--|---\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m---|--\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m----|-\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m-----|\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m----|-\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m---|--\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m--|---\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m-|----\e[0m]\e[0K $@\r"; sleep $DELAY
            echo -ne "[\e[1;36m|-----\e[0m]\e[0K $@\r"; sleep $DELAY
        done
    }

    ui::begin() {
        echo -ne "[\e[1;36m------\e[0m] $@\r"
        tput civis
        ui::spin "$@" >&2 &
        export MAGEOPS_UI_SPINJOBS="$MAGEOPS_UI_SPINJOBS $!"
    }

    ui::finish() {
        [ -z "$MAGEOPS_UI_SPINJOBS" ] || kill $MAGEOPS_UI_SPINJOBS && export MAGEOPS_UI_SPINJOBS=""
        ui::overw
        tput cnorm
    }


    ui::step() {
        local LABEL="$1"; shift

        ui::debugcmd "$@" >&2
        ui::begin "$LABEL" >&2

        set +e
        exec 3>&1
        CMD_ERR="$(eval "$@" 2>&1 >&3)"
        RESULT=$?
        set -e
        
        ui::finish "$LABEL" >&2

        if [ $RESULT -gt 0 ]  ; then
            ui::fail "$LABEL \n\e[1;31m     <$RESULT> \e[0;31mFailed command:\e[0m $(ui::q $(echo "$@"))\n$(echo "$CMD_ERR" | sed -E 's/^/     \\e[1;31m<<<\\e[0;31m /g')\e[0m"
            return $RESULT
        else
            ui::ok "$LABEL" >&2
        fi
    }
}
