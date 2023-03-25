# Section: utils
BEGIN{
    UI_ADVISE_WARN = "\033[33;1m"
    UI_ADVISE_END  = "\033[0m"
    if( ADVISE_NO_COLOR == true ) UI_ADVISE_WARN = UI_ADVISE_END = ""
    # EXIT_CODE = 0
}

function advise_panic(msg){
    CAND[ "MESSAGE" ] = jqu(msg)
    return false
}

function str_escape_special_char(s){
    gsub(":", "\\:", s)
    # if (ZSHVERSION == "") gsub(" ", "\\\\ ", s)
    return s
}

function parse_candidate_arr( arr,      s, i, l, _, v, d, _cand_exec, _cand_msg ){
    if ((_cand_msg = arr[ "MESSAGE" ]) != "") return "_message_str='" UI_ADVISE_WARN "[ADVISE PANIC]: " juq(_cand_msg) UI_ADVISE_END "'"
    s = "offset=" arr[ "OFFSET" ] "\n"
    if ((l = arr[ "EXEC" L ]) > 0) {
        for (i=1; i<=l; ++i){
            s = s "candidate_exec=\"" juq(arr[ "EXEC", i ]) "\";\n"
        }
    }
    if ((l = arr[ "CODE" L ]) > 0) {
        s = s "candidate_arr=(\n"
        for (i=1; i<=l; ++i){
            v = arr[ "CODE", i ]
            d = arr[ "CODE", v ]
            v = juq(v)
            if (d != "\"\"") s = s shqu1( str_escape_special_char(v) ":" juq(d) ) "\n"
            else s = s shqu1( str_escape_special_char(v) ) "\n"
        }
        s = s ")\n"
    }
    return s
}

## EndSection
