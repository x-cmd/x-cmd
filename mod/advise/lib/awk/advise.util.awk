function advise_panic(msg){
    CAND[ "MESSAGE" ] = jqu(msg)
    return false
}

function str_escape_special_char(s){
    gsub(":", "\\:", s)
    # if (ZSHVERSION == "") gsub(" ", "\\\\ ", s)
    return s
}

function comp_advise_parse_candidate_arr( arr,      s, i, l, _, v, d, _cand_exec, _cand_msg, _ui_warn, _ui_end, kp ){
    _ui_warn = "\033[33;1m"
    _ui_end  = "\033[0m"
    if( ADVISE_NO_COLOR == true ) _ui_warn = _ui_end = ""

    if ((_cand_msg = arr[ "MESSAGE" ]) != "") return "_message_str='" _ui_warn "[ADVISE PANIC]: " juq(_cand_msg) _ui_end "'"
    s = "offset=" arr[ "OFFSET" ] "\n"
    if ((l = arr[ "EXEC" L ]) > 0) {
        for (i=1; i<=l; ++i){
            s = s "candidate_exec=" qu1(juq(arr[ "EXEC", i ])) ";\n"
        }
    }
    kp = CAND[ "KEYPATH" ]
    if ( CAND[ kp, "IS_NOSPACE" ] == true ) {
        s = s "candidate_prefix=" qu1(CAND[ kp, "PREFIX" ]) ";\n"
    }

    if ((l = arr[ "CODE" L ]) > 0) {
        s = s "candidate_arr=(\n"
        for (i=1; i<=l; ++i){
            v = arr[ "CODE", i ]
            d = arr[ "CODE", v ]
            v = juq(v)
            gsub(" ", "\\ ", v)
            if (d != "\"\"") s = s qu1( str_escape_special_char(v) ":" juq(d) ) "\n"
            else s = s qu1( str_escape_special_char(v) ) "\n"
        }
        s = s ")\n"
    }
    if ((l = arr[ "NOSPACE" L ]) > 0) {
        s = s "candidate_nospace_arr=(\n"
        for (i=1; i<=l; ++i){
            v = arr[ "NOSPACE", i ]
            d = arr[ "NOSPACE", v ]
            v = juq(v)
            gsub(" ", "\\ ", v)
            if (d != "\"\"") s = s qu1( str_escape_special_char(v) ":" juq(d) ) "\n"
            else s = s qu1( str_escape_special_char(v) ) "\n"
        }
        s = s ")\n"
    }
    return s
}

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
