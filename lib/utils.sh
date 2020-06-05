# Just a reusable library for nice output with automation scripts
# which I wrote for an unrelated private project. /FS

set -euo pipefail

export _DEBUG="${_DEBUG:-false}"
export _LSPINJOBS=""

trap '[ $? -eq 0 ] && lcleanup && exit 0; lemerg' EXIT HUP QUIT INT

lok()    { echo -e  "[\e[1;32m  OK  \e[0m] $@" ; }
linfo()  { echo -e  "[\e[1;34m INFO \e[0m] $@" ; }
lhdr()   { echo -e  "[\e[1;36m STEP \e[0m] \n\n  ----------  \e[1;36m$@\e[0m  ----------  \n" ; }
lwarn()  { echo -e  "[\e[1;33m WARN \e[0m] $@" >&2 ; }
lfail()  { echo -e  "[\e[1;31mFAILED\e[0m] $@" >&2 ; }
lcrit()  { echo -e  "[\e[1;35m CRIT \e[0m] $@" >&2 ; }
ldone()  { echo -e  "[\e[1;32m DONE \e[0m] $@" ; }
ldebug() { ! $_DEBUG || echo -e  "[\e[2m DBUG \e[0m] $@" >&2 ; }
lq()     { echo -ne "\e[36m$@\e[0m" ; }
loverw() { echo -ne "\e[0K\r" ; }
lcmd()  { ldebugcmd "$@"; "$@"; }
lqcmd() { while (( $# > 0 )) ; do echo -ne "'$1' "; shift; done; }
ldebugcmd() { ldebug "Cmd: $(lq $(echo "$@"))" ; }
lfsize() { ls -sh1 "$@" | cut -d' ' -f1; }
lcleanup() { echo; tput cnorm; kill $_LSPINJOBS &>/dev/null || true; rm -f *.tmp || true; }; trap 'lcleanup' EXIT HUP QUIT
lemerg() {
    local RESULT="${1:-9}"
    lcleanup
    lcrit "Critical error, exit with code $(lq $RESULT)"
    exit $RESULT
}

lspin() {
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

lbegin() {
    echo -ne "[\e[1;36m------\e[0m] $@\r"
    tput civis
    lspin "$@" >&2 &
    export _LSPINJOBS="$_LSPINJOBS $!"
}

lend() {
    [ -z "$_LSPINJOBS" ] || kill $_LSPINJOBS && export _LSPINJOBS=""
    loverw
    tput cnorm
}


lstep() {
    local LABEL="$1"; shift

    ldebugcmd "$@" >&2
    lbegin "$LABEL" >&2

    set +e
      exec 3>&1
      CMD_ERR="$(eval "$@" 2>&1 >&3)"
      RESULT=$?
    set -e
    
    lend "$LABEL" >&2

    if [ $RESULT -gt 0 ]  ; then
        lfail "$LABEL \n\e[1;31m     <$RESULT> \e[0;31mFailed command:\e[0m $(lq $(echo "$@"))\n$(echo "$CMD_ERR" | sed -E 's/^/     \\e[1;31m<<<\\e[0;31m /g')\e[0m"
        return $RESULT
    else
        lok "$LABEL" >&2
    fi
}

