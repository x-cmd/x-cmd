# Error handling and result formatting utilities

# Sets an error message in the CAND array
# Returns false to signal error condition
function advise_error(msg){
    CAND[ "MESSAGE" ] = (msg ~ "^\"") ? msg : jqu(msg)
    return false
}

# Formats a completion candidate with optional description
# Handles shell-specific escaping (zsh uses colons, others use \002)
#
# Parameters:
#   v - The value/candidate
#   d - Description (may be empty)
#
# Returns: Formatted string ready for shell completion
function comp_advise_str_style(v, d,      _res){
    if ( ___X_CMD_SHELL == "zsh" ){
        gsub(":", "\\:", v)
        if ((d != "") && ( ADVISE_WITHOUT_DESC != 1 ))  _res = v ":" d
        else                                            _res = v
    } else if ((d != "") && ( ADVISE_WITHOUT_DESC != 1 )) {
        _res = v "\002" d
    } else {
        _res = v
    }
    return qu1(_res)
}

# Formats the CAND array into shell-readable output
# Generates shell variable assignments for completion
#
# Output format:
#   offset=N
#   candidate_exec="cmd";
#   candidate_arr=(
#   "value:description"
#   ...
#   )
function comp_advise_parse_candidate_arr( arr,      s, i, l, _, v, d, _cand_exec, _cand_msg, _ui_warn, _ui_end, kp ){
    _ui_warn = "\033[33;1m"
    _ui_end  = "\033[0m"
    if( ADVISE_NO_COLOR == true ) _ui_warn = _ui_end = ""

    # Handle error messages
    if ((_cand_msg = arr[ "MESSAGE" ]) != "") return "_message_str='" _ui_warn "[ADVISE PANIC]: " juq(_cand_msg) _ui_end "'"

    # Basic info: offset for cursor positioning
    s = "offset=" arr[ "OFFSET" ] "\n"

    # Dynamic execution candidates
    l = arr[ "EXEC" L ]
    for (i=1; i<=l; ++i)    s = s "candidate_exec=" qu1(juq(arr[ "EXEC", i ])) ";\n"

    l = arr[ "EXEC_STDOUT" L ]
    for (i=1; i<=l; ++i)    s = s "candidate_exec_stdout=" qu1(juq(arr[ "EXEC_STDOUT", i ])) ";\n"

    l = arr[ "EXEC_STDOUT_NOSPACE" L ]
    for (i=1; i<=l; ++i)    s = s "candidate_exec_stdout_nospace=" qu1(juq(arr[ "EXEC_STDOUT_NOSPACE", i ])) ";\n"

    # Nospace prefix for partial completions
    kp = CAND[ "KEYPATH" ]
    if ( CAND[ kp, "IS_NOSPACE" ] == true ) {
        s = s "candidate_prefix=" qu1(CAND[ kp, "PREFIX" ]) ";\n"
    }

    # Regular completion candidates
    if ((l = arr[ "CODE" L ]) > 0) {
        s = s "candidate_arr=(\n"
        for (i=1; i<=l; ++i){
            v = arr[ "CODE", i ]
            d = arr[ "CODE", v ]
            v = juq(v)
            gsub(" ", "\\ ", v)
            s = s comp_advise_str_style(v, juq(d)) "\n"
        }
        s = s ")\n"
    }

    # Nospace candidates (for --option=value style)
    if ((l = arr[ "NOSPACE" L ]) > 0) {
        s = s "candidate_nospace_arr=(\n"
        for (i=1; i<=l; ++i){
            v = arr[ "NOSPACE", i ]
            d = arr[ "NOSPACE", v ]
            v = juq(v)
            gsub(" ", "\\ ", v)
            s = s comp_advise_str_style(v, juq(d)) "\n"
        }
        s = s ")\n"
    }
    return s
}

# Resolves advise file paths from URI-style references
#
# Supports:
#   x-advise://mod/file -> $___X_CMD_ROOT_ADV/mod/file
#   x-cmd-advise://name -> $___X_CMD_ADVISE_MAN_XCMD_FOLDER/name
function comp_advise_get_ref_adv_jso_filepath( str ) {
    if (match(str, "^x-advise://")) {
        str = substr( str, RLENGTH+1 )
        if ( str ~ "/" ) return ___X_CMD_ROOT_ADV "/" str
        return ___X_CMD_ROOT_ADV "/" str "/advise.jso"
    }
    else if (match(str, "^x-cmd-advise://")) {
        str = substr( str, RLENGTH+1 )
        if ( str ~ "/" ) return ___X_CMD_ADVISE_MAN_XCMD_FOLDER "/" str
        return ___X_CMD_ADVISE_MAN_XCMD_FOLDER "/" str "/advise.t.jso"
    }
    return str
}
