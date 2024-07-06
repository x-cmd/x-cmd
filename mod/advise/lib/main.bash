# shellcheck shell=bash disable=SC2207,2206,2034

___x_cmd_advise_run(){
    ___x_cmd_awk___get_utf8_
    local _UTF8="$___X_CMD_AWK_LANGUAGE_UTF8"
    local name="${1:-${COMP_WORDS[0]}}"
    local x_=;  ___x_cmd_advise_run_filepath_ "$___X_CMD_ADVISE_RUN_CMD" "$name" || return

    # Only different from main.3.bash, for words in COMP_WORDBREAKS
    if [ -z "$___X_CMD_ADVISE_SHELL_BASH_LT_4_2" ]; then
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

    # Reduce trigger times
    [ "$___X_CMD_ADVISE_LAST_BASH_COMP_LINE" != "$COMP_LINE" ] || return 0
    ___X_CMD_ADVISE_LAST_BASH_COMP_LINE="$COMP_LINE"

    # Used in `eval "$candidate_exec"`
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMP_WORDS=("${COMP_WORDS[@]:0:$((COMP_CWORD+1))}")

    local candidate_arr=(); local candidate_exec_arr=(); local candidate_nospace_arr=();
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

    local maxitem="${___X_CMD_ADVISE_MAX_ITEM:-0}"
    COMPREPLY=( "${COMPREPLY[@]:0:$maxitem}" )
    maxitem="$(( maxitem - ${#COMPREPLY[@]} ))"

    LC_ALL="$_UTF8" LANG="$_UTF8" COMPREPLY+=( $(
        {
            [ -z "${candidate_arr[*]}" ] || printf " \002%s\n" "${candidate_arr[@]}"
            [ -z "${candidate_nospace_arr[*]}" ] || printf "\002%s\n" "${candidate_nospace_arr[@]}"
        } | ___x_cmd_cmds_awk -v FS="\002" -v current="$cur" -v maxitem="$maxitem" \
            -v ADVISE_WITHOUT_DESC="$___X_CMD_ADVISE_WITHOUT_DESC" -v candidate_prefix="$candidate_prefix" \
            -f "$___X_CMD_ROOT_MOD/advise/lib/awk/advise/advise.bash.compgen_wordlist.awk"
    ) )

    ___x_cmd_advise___ltrim_bash_completions "$old_cur" "@" ":" "="
}
