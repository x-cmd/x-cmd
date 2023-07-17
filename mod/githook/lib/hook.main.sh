#shellcheck shell=dash

___x_cmd_githook_find_folder_(){
    local TGT_FOLDER="$1"
    local cur="$PWD"

    while [ ! "$cur" = "" ]; do
        if [ -d "$cur/$TGT_FOLDER" ]; then
            ___X_CMD_GITHOOK_FIND_FOLDER_="$cur"
            return 0
        fi
        cur=${cur%/*}
    done
    return 1
}

___x_cmd_githook_find_folder_ .x-cmd
___X_CMD_GITHOOK_WSROOT="$___X_CMD_GITHOOK_FIND_FOLDER_"

[ -f "$___X_CMD_GITHOOK_WSROOT/.x-cmd/git/hook.yml" ] || return 0

if [ -n "$GIT_DIR" ]; then
    cd "$GIT_DIR"
    ___X_CMD_GITHOOK_GIT_DIR="$PWD"
    cd "$OLDPWD"
else
    ___x_cmd_githook_find_folder_ .git
    ___X_CMD_GITHOOK_GIT_DIR="${___X_CMD_GITHOOK_FIND_FOLDER_}/.git"
fi

[ "$PWD/.x-cmd/git/hook.yml" -ot "${___X_CMD_GITHOOK_GIT_DIR}/.x-cmd/hooks" ] || (
    . $___X_CMD_ROOT_MOD/../X
    x log :info "Apply githook for modification detected in $PWD/.x-cmd/git/hook.yml"
    x githook apply "$PWD/.x-cmd/git/hook.yml" "${___X_CMD_GITHOOK_GIT_DIR}/.x-cmd/hooks"
)

[ -f "$___X_CMD_GITHOOK_GIT_DIR/.x-cmd/hooks/${___X_CMD_GITHOOK_HOOKNAME}" ] || return 0
. "$___X_CMD_GITHOOK_GIT_DIR/.x-cmd/hooks/${___X_CMD_GITHOOK_HOOKNAME}"
