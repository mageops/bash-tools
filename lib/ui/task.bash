ui::task::__module__() {
    lib::import ui::core
    lib::import ui::color

    export MAGEOPS_UI_SPINJOBS=""

    lib::cleanup::hook ui::task::cleanup

    ui::task::cleanup() {
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

    ui::cmd()         { ui::cmd::debug "$@"; "$@"; }
    ui::cmd::quote()  { while (( $# > 0 )) ; do echo -ne "'$1' "; shift; done; }
    ui::cmd::debug()  { ui::debug "Cmd: $(ui::em $(echo "$@"))" ; }

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
        if ! $UI_TTY_HAS ; then
            echo -e "[\e[1;36m  ->  \e[0m] $@"
            return 0
        fi

        echo -ne "[\e[1;36m------\e[0m] $@\r"
        tput civis
        ui::spin "$@" >&2 &
        export MAGEOPS_UI_SPINJOBS="$MAGEOPS_UI_SPINJOBS $!"
    }

    ui::finish() {
        $UI_TTY_HAS|| return 0
        [ -z "$MAGEOPS_UI_SPINJOBS" ] || kill $MAGEOPS_UI_SPINJOBS && export MAGEOPS_UI_SPINJOBS=""
        ui::cr
        tput cnorm
    }


    ui::step() {
        local LABEL="$1"; shift

        ui::cmd::debug "$@" >&2
        ui::begin "$LABEL" >&2

        set +e
        exec 3>&1
        CMD_ERR="$(eval "$@" 2>&1 >&3)"
        RESULT=$?
        set -e
        
        ui::finish "$LABEL" >&2

        if [ $RESULT -gt 0 ]  ; then
            ui::fail "$LABEL \n\e[1;31m     <$RESULT> \e[0;31mFailed command:\e[0m $(ui::em $(echo "$@"))\n$(echo "$CMD_ERR" | sed -E 's/^/     \\e[1;31m<<<\\e[0;31m /g')\e[0m"
            return $RESULT
        else
            ui::ok "$LABEL" >&2
        fi
    }
}
