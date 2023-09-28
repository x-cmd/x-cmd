# shellcheck shell=zsh

___x_cmd_advise_run(){
    [ -n "$___X_CMD_ADVISE_LANGUAGE_UTF8" ] || ___x_cmd_advise_run___get_utf8
    local _UTF8="$___X_CMD_ADVISE_LANGUAGE_UTF8"
    local COMP_WORDS=("${words[@]:0:$CURRENT}")
    local COMP_CWORD="$(( CURRENT-1 ))"

    [ -z "$___X_CMD_ADVISE_RUN_CMD_FOLDER" ] && ___X_CMD_ADVISE_RUN_CMD_FOLDER="$___X_CMD_ADVISE_TMPDIR"
    local name="${1:-${COMP_WORDS[1]}}"
    local ___X_CMD_ADVISE_RUN_FILEPATH_;  ___x_cmd_advise_run_filepath_ "$name" || return 1
    [ "$___X_CMD_ADVISE_RUN_CMD_FOLDER" != "$___X_CMD_ADVISE_MAN_XCMD_FOLDER" ] || ___x_cmd_advise___load_xcmd_advise_util_file "$name"

    # Used in `eval "$candidate_exec"`
    local cur="${COMP_WORDS[CURRENT]}"

    local candidate_arr;            LANG="$_UTF8" candidate_arr=()
    local candidate_nospace_arr;    LANG="$_UTF8" candidate_nospace_arr=()
    local candidate_exec=; local _message_str=; local ___X_CMD_ADVISE_RUN_SET_NOSPACE=; local candidate_prefix=
    local offset
    setopt aliases
    eval "$(___x_cmd_advise_get_result_from_awk "$___X_CMD_ADVISE_RUN_FILEPATH_")" 2>/dev/null

    cur="${cur#"$candidate_prefix"}"
    local IFS="$___X_CMD_ADVISE_IFS_INIT"
    local candidate_exec_arr;       LANG="$_UTF8" candidate_exec_arr=()
    eval "$candidate_exec" 2>/dev/null

    [ -z "$_message_str" ]       || LANG="$_UTF8" _message -r "$_message_str"
    [ -z "$candidate_arr" ]      || LANG="$_UTF8" ___x_cmd_advise_run___describe 'commands' candidate_arr
    [ -z "$candidate_exec_arr" ] || LANG="$_UTF8" ___x_cmd_advise_run___describe 'commands' candidate_exec_arr
    [ -z "$candidate_nospace_arr" ] || LANG="$_UTF8" ___X_CMD_ADVISE_RUN_SET_NOSPACE=1 ___x_cmd_advise_run___describe 'commands' candidate_nospace_arr
}

___x_cmd_advise_run___describe(){
	compadd(){
		builtin compadd \
            ${___X_CMD_ADVISE_RUN_SET_NOSPACE:+"-S"} ${___X_CMD_ADVISE_RUN_SET_NOSPACE:+""} \
            ${candidate_prefix:+"-P"} ${candidate_prefix:+"$candidate_prefix"} \
            "$@"
	}
	_describe "$@"
	unset -f compadd
}

___x_cmd_advise_run___get_utf8(){
    ___X_CMD_ADVISE_LANGUAGE_UTF8=C.utf8
    local l=; l="$( locale -a | grep -i -e utf8 -e utf-8 | head -n 1 )" 2>/dev/null
    [ -z "$l" ] || ___X_CMD_ADVISE_LANGUAGE_UTF8="$l"
}
