# shellcheck shell=bash disable=SC2207,2206,2034

___x_cmd_advise_run(){
    local name="${1:-${COMP_WORDS[0]}}"
    local x_=;  ___x_cmd_advise_run_filepath_ "$___X_CMD_ADVISE_RUN_CMD" "$name" || return

    # Only different from main.3.bash, for words in COMP_WORDBREAKS
    if [ -z "$___X_CMD_ADVSIE_SHELL_BASH_LT_4_2" ]; then
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
    fi

    # Used in `eval "$candidate_exec"`
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMP_WORDS=("${COMP_WORDS[@]:0:$((COMP_CWORD+1))}")

    local candidate_arr; local candidate_exec_arr; local candidate_nospace_arr;
    local candidate_exec=; local offset=; local ___X_CMD_ADVISE_RUN_SET_NOSPACE=; local candidate_prefix=
    local candidate_exec_stdout=;   local candidate_exec_stdout_nospace=
    eval "$(___x_cmd_advise_get_result_from_awk "$x_")" 2>/dev/null

    local IFS="$___X_CMD_ADVISE_IFS_INIT"
    local old_cur="$cur"
    cur="${cur#"$candidate_prefix"}"
    [ -z "$candidate_exec" ]                || eval "$candidate_exec" 2>/dev/null 1>&2
    [ -z "$candidate_exec_stdout" ]         || ___x_cmd_advise_exec___stdout
    [ -z "$candidate_exec_stdout_nospace" ] || ___x_cmd_advise_exec___stdout_nospace
    [ -z "${candidate_exec_arr[*]}" ]       || candidate_arr+=( "${candidate_exec_arr[@]}" )
    [ -z "${candidate_arr[*]}" ]            || COMPREPLY+=( $( ___x_cmd_advise_run___compgen_wordlist "$cur" "${candidate_arr[@]}" ) )
    [ -z "${candidate_nospace_arr[*]}" ]    || COMPREPLY+=( $( ___X_CMD_ADVISE_RUN_SET_NOSPACE=1 ___x_cmd_advise_run___compgen_wordlist "$cur" "${candidate_nospace_arr[@]}" ) )
    ___x_cmd_advise___ltrim_bash_completions "$old_cur" "@" ":" "="
}

___x_cmd_advise_run___compgen_wordlist(){
    local cur="$1"; shift
    local i=; for i in "$@"; do
        [ -n "$i" ] || continue
        [ -n "$___X_CMD_ADVISE_RUN_SET_NOSPACE" ] || i="${i} "
        [[ "$i" == $cur* ]] || continue
        [ -z "$candidate_prefix" ] || i="${candidate_prefix}${i}"
        printf "%s\n" "${i}"
    done | uniq 2>/dev/null
}


