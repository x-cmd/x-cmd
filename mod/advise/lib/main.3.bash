# shellcheck shell=bash disable=SC2207,2034

___advise_run(){
    [ -z "$___ADVISE_RUN_CMD_FOLDER" ] && ___ADVISE_RUN_CMD_FOLDER="$___X_CMD_ADVISE_TMPDIR"

    local ___ADVISE_RUN_FILEPATH_;  ___advise_run_filepath_ "${1:-${COMP_WORDS[0]}}" || return 1

    # Used in `eval "$candidate_exec"`
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local COMP_WORDS=("${COMP_WORDS[@]:0:$((COMP_CWORD+1))}")

    local candidate_arr
    local candidate_exec
    local offset
    eval "$(___advise_get_result_from_awk  "$___ADVISE_RUN_FILEPATH_")" 2>/dev/null

    local IFS="$___X_CMD_ADVISE_IFS_INIT"
    local candidate_exec_arr
    eval "$candidate_exec" 2>/dev/null

    COMPREPLY=( "${COMPREPLY[@]}" $( compgen -W "${candidate_arr[*]} ${candidate_exec_arr[*]}" -- "$cur"))
    __ltrim_bash_completions "$cur" "@" ":" "="
}
