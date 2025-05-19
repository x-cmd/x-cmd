
___x_cmd_ssh_x_setup___log(){
    printf "%s\n" "- I|x: $*" >&2
}

___x_cmd_ssh_x_setup___main(){
    ___X_CMD_ROOT="$HOME/.x-cmd.root"
    ___X_CMD_VERSION="${1:-"$___X_CMD_VERSION"}"
    ___X_CMD_WEBSRC_REGION="${2:-"$___X_CMD_WEBSRC_REGION"}"

    ! { command -v x >/dev/null 2>&1 || command -v x-cmd >/dev/null 2>&1 || [ -f /bin/x-cmd ] || [ -f "$___X_CMD_ROOT/X" ]; } || {
        ___x_cmd_ssh_x_setup___log "x-cmd is already installed  in the destination environment for SSH"
        return 0
    }

    [ -n "$___X_CMD_VERSION" ] || {
        ___x_cmd_ssh_x_setup___log "Please specify the version of x-cmd"
        return 1
    }

    local tardir="$___X_CMD_ROOT/v/$___X_CMD_VERSION"
    ___x_cmd_ssh_x_setup___log "Populate x-cmd to $HOME/.x-cmd.root"
    if [ -d "$tardir" ]; then
        ___x_cmd_ssh_x_setup___log "Already existed $tardir"
    else
        local tgzfile="$___X_CMD_ROOT/global/shared/version/archive/$___X_CMD_VERSION.tgz"
        command mkdir -p "$tardir"
        LC_ALL="$___X_CMD_LOCALE_DEF_C" command tar -xzf "$tgzfile" -C "$tardir" || return 1
    fi

    ___X_CMD_ROOT="$___X_CMD_ROOT"          \
    ___X_CMD_VERSION="$___X_CMD_VERSION"    \
    ___X_CMD_ROOT_CODE=""                   \
    ___X_CMD_ROOT_MOD=""                    \
    ___X_CMD_ADVISE_DISABLE=1               \
    ___X_CMD_WEBSRC_REGION="$___X_CMD_WEBSRC_REGION" \
    sh -c '
        . "$___X_CMD_ROOT/v/$___X_CMD_VERSION/X";
        ___x_cmd boot init "$___X_CMD_ROOT" "$___X_CMD_VERSION";
    ' || return 1

    ___X_CMD_ROOT_CODE=;
    . "$___X_CMD_ROOT/v/$___X_CMD_VERSION/X";
}
