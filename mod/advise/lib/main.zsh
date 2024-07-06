# shellcheck shell=zsh

xrc awk
___x_cmd_advise_run(){
    ___x_cmd_awk___get_utf8_
    local _UTF8="$___X_CMD_AWK_LANGUAGE_UTF8"
    local COMP_WORDS=("${words[@]:0:$CURRENT}")
    local COMP_CWORD="$(( CURRENT-1 ))"

    local name="${1:-${COMP_WORDS[1]}}"
    local x_=;  ___x_cmd_advise_run_filepath_ "$___X_CMD_ADVISE_RUN_CMD" "$name" || return

    local cur="${COMP_WORDS[CURRENT]}"
    local candidate_arr=(); local candidate_exec_arr=(); local candidate_nospace_arr=();
    local candidate_exec=; local offset=; local ___X_CMD_ADVISE_RUN_SET_NOSPACE=; local candidate_prefix=
    local candidate_exec_stdout=;   local candidate_exec_stdout_nospace=
    setopt aliases
    eval "$(___x_cmd_advise_get_result_from_awk "$x_")" 2>/dev/null

    cur="${cur#"$candidate_prefix"}"
    local IFS="$___X_CMD_ADVISE_IFS_INIT"
    [ -z "$candidate_exec" ]                || eval "$candidate_exec" 2>/dev/null 1>&2
    [ -z "$candidate_exec_stdout" ]         || ___x_cmd_advise_exec___stdout
    [ -z "$candidate_exec_stdout_nospace" ] || ___x_cmd_advise_exec___stdout_nospace

    [ -z "$_message_str" ]                  || LC_ALL="$_UTF8" LANG="$_UTF8" _message -r "$_message_str"
    [ -z "${candidate_exec_arr[*]}" ]       || candidate_arr+=( "${candidate_exec_arr[@]}" )
    ___x_cmd_advise_run___ltrim_maxitem
    ___x_cmd_advise_run___fix_mac_zsh

    [ -z "${candidate_arr[*]}" ]            || LC_ALL="$_UTF8" LANG="$_UTF8" ___x_cmd_advise_run___describe 'commands' candidate_arr || return
    [ -z "${candidate_nospace_arr[*]}" ]    || LC_ALL="$_UTF8" LANG="$_UTF8" ___X_CMD_ADVISE_RUN_SET_NOSPACE=1 ___x_cmd_advise_run___describe 'commands' candidate_nospace_arr
}

___x_cmd_advise_run___describe(){
	compadd(){
		builtin compadd \
            ${___X_CMD_ADVISE_RUN_SET_NOSPACE:+"-S"} ${___X_CMD_ADVISE_RUN_SET_NOSPACE:+""} \
            ${candidate_prefix:+"-P"} ${candidate_prefix:+"$candidate_prefix"} \
            "$@"
	}
	_describe "$@"
    local _exitcode="$?"
	unset -f compadd
    return "$_exitcode"
}

___x_cmd_advise_run___ltrim_maxitem(){
    local IFS="$___X_CMD_ADVISE_IFS_INIT"
    local maxitem="${___X_CMD_ADVISE_MAX_ITEM:-99}"
    local candidata_arr_item="${#candidate_arr[@]}"
    if [ "$maxitem" -gt "$candidata_arr_item" ]; then
        maxitem=$(( maxitem - candidata_arr_item ))
        candidate_nospace_arr=( "${candidate_nospace_arr[@]:0:$maxitem}" )
    else
        candidate_arr=( "${candidate_arr[@]:0:$maxitem}" )
        candidate_nospace_arr=()
    fi
}

___x_cmd_advise_run___fix_mac_zsh(){
    ___x_cmd os is darwin || return
    local n="${#candidate_arr[@]}"
    [ $n = 2 ] || return
    candidate_arr=( $( printf "%s\n" "${candidate_arr[@]}" | ___x_cmd_cmds sort -r ) )
}
