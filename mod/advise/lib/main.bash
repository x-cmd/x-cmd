# shellcheck shell=bash disable=SC2207,2206,2034

___x_cmd_advise_run(){
    [ -z "$___X_CMD_ADVISE_RUN_CMD_FOLDER" ] && ___X_CMD_ADVISE_RUN_CMD_FOLDER="$___X_CMD_ADVISE_TMPDIR"
    local name="${1:-${COMP_WORDS[0]}}"
    local ___X_CMD_ADVISE_RUN_FILEPATH_;  ___x_cmd_advise_run_filepath_ "$name" || return 1
    [ "$___X_CMD_ADVISE_RUN_CMD_FOLDER" != "$___X_CMD_ADVISE_MAN_XCMD_FOLDER" ] || ___x_cmd_advise___load_xcmd_advise_util_file "$name"
    {   # Only different from main.3.bash, for words in COMP_WORDBREAKS
        local last="${COMP_WORDS[COMP_CWORD]}"
        local tmp=
        case "$last" in
            \"*|\'*)
                COMP_LINE="${COMP_LINE%"$last"}"
                tmp=( $COMP_LINE ); tmp+=("$last")
                COMP_WORDS=("${tmp[@]}")
                COMP_CWORD="$(( ${#tmp[@]}-1 ))"
                ;;
        esac
        # [ "${COMP_LINE% }" = "${COMP_LINE}" ] || tmp+=( "" )        # Ends with space
    }
    # Used in `eval "$candidate_exec"`
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local COMP_WORDS=("${COMP_WORDS[@]:0:$((COMP_CWORD+1))}")

    local candidate_arr
    local candidate_exec
    local offset
    eval "$(___x_cmd_advise_get_result_from_awk "$___X_CMD_ADVISE_RUN_FILEPATH_")" 2>/dev/null

    local IFS="$___X_CMD_ADVISE_IFS_INIT"
    local candidate_exec_arr
    eval "$candidate_exec" 2>/dev/null
    [ -z "$candidate_arr" ] || COMPREPLY+=( "${candidate_arr[@]}" )
    COMPREPLY+=( $( compgen -W "${candidate_exec_arr[*]}" -- "$cur") )
    ___x_cmd_advise___ltrim_bash_completions "$cur" "@" ":" "="
}
