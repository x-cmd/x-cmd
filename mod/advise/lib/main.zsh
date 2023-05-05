# shellcheck shell=zsh

___x_cmd_advise_run(){
    local COMP_WORDS=("${words[@]:0:$CURRENT}")
    local COMP_CWORD="$(( CURRENT-1 ))"

    [ -z "$___X_CMD_ADVISE_RUN_CMD_FOLDER" ] && ___X_CMD_ADVISE_RUN_CMD_FOLDER="$___X_CMD_ADVISE_TMPDIR"
    local name="${1:-${COMP_WORDS[1]}}"
    local ___X_CMD_ADVISE_RUN_FILEPATH_;  ___x_cmd_advise_run_filepath_ "$name" || return 1
    [ "$___X_CMD_ADVISE_RUN_CMD_FOLDER" != "$___X_CMD_ADVISE_MAN_XCMD_FOLDER" ] || ___x_cmd_advise___load_xcmd_advise_util_file "$name"

    # Used in `eval "$candidate_exec"`
    local cur="${COMP_WORDS[CURRENT]}"

    local candidate_arr
    local candidate_exec
    local _message_str
    local offset
    setopt aliases
    eval "$(___x_cmd_advise_get_result_from_awk "$___X_CMD_ADVISE_RUN_FILEPATH_")" 2>/dev/null

    local IFS="$___X_CMD_ADVISE_IFS_INIT"
    local candidate_exec_arr
    eval "$candidate_exec" 2>/dev/null

    [ -z "$candidate_arr" ] || LANG=en_US.UTF-8 _describe 'commands' candidate_arr
    [ -z "$candidate_exec_arr" ] || LANG=en_US.UTF-8 _describe 'commands' candidate_exec_arr
    [ -z "$_message_str" ] || LANG=en_US.UTF-8 _message -r "$_message_str"
}
