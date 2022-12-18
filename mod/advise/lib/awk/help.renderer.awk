BEGIN{
    HELP_INDENT_LEN = 4;    HELP_INDENT_STR = "    "
    DESC_INDENT_LEN = 3;    DESC_INDENT_STR = "   "

    if (NO_COLOR != true ) {
        UI_TIP_INFO     = "\033[32m"
        UI_TIP_NOTE     = "\033[36m"
        UI_TIP_WARN     = "\033[33m"
        UI_TIP_DANGER   = "\033[31m"

        UI_TITLE        = "\033[1m"
        UI_DESC         = "\033[91m"
        UI_END          = "\033[0m"
        UI_THEME        = ( UI_THEME_COLOR  == "" ) ? "\033[36m" : UI_THEME_COLOR
    }

}

function arr_clone_of_kp( src, dst, kp,       l, i ){
    dst[ L ] = l = src[ kp L ]
    for (i=1; i<=l; ++i)  dst[i] = src[ ( (kp != "") ? kp SUBSEP : kp ) i]
    return l
}

function str_cut_line( _line, indent,          l, i, arr, _str ){
    l = split( _line, arr, "\n")
    _str =  str_cut_line_(arr[1], indent)
    for(i=2; i<=l; ++i) _str = _str "\n" str_rep(" ", indent) str_cut_line(arr[i], indent)
    return _str
}

function str_cut_line_( _line, indent,               _max_len, _len, l, i){
    if( COLUMNS == "" )     return _line

    _max_len = COLUMNS - indent
    if ( length(_line) < _max_len )  return _line

    l = split( _line, _arr, " " )
    if ( length(_arr[1]) < _max_len ){
        for(i=1; i<=l; ++i){
            _len += ( length(_arr[i]) + 1)
            if (_len >= _max_len) {
                _len -= ( length(_arr[i]) + 1 )
                break
            }
        }
    }
    else _len = _max_len
    return substr(_line, 1, _len) "\n" str_rep(" ", indent)  str_cut_line( substr(_line, _len + 1 ), indent )
}

function get_option_string( kp, v,         _str, _synopsis_str){
    _str = juq(v)
    gsub("\\|", ",", _str)
    _synopsis_str = aobj_get_special_value(obj, kp SUBSEP v, "synopsis")
    if ( (_synopsis_str != "[") && ( _synopsis_str != "null") ) _str = _str " " juq( _synopsis_str )
    return _str
}

function generate_title(v){ return UI_TITLE v UI_END ;  }
function generate_help_for_namedoot_cal_maxlen_desc( kp, _text_arr,            l, i, _len, _max_len, _opt_help_doc ){
    l = arr_len(_text_arr)
    for ( i=1; i<=l; ++i ) {
        _text_arr[ i ]   = _opt_help_doc     = get_option_string( kp, _text_arr[ i ] )
        _text_arr[ i L ] = _len              = length( _opt_help_doc )        # TODO: Might using wcswidth
        if ( _len > _max_len )    _max_len = _len
    }
    return _max_len
}

function generate_optarg_rule_string_inner(kp, tag,          _str, _dafault, _regexl, _candl, i, _cand_id_arr, _kl, _k_id, _k_id_arr){
    _default = aobj_get_default(obj, kp)
    if (_default != "" ) _str = _str " [default: " juq(_default) "]"

    _regex_id = aobj_get_special_value_id( kp, "regex")
    _regexl  = aobj_len(obj, _regex_id)
    if ( _regexl > 0 ) {
        _str = _str " [regex: "
        _str = _str juq( aobj_get(obj, _regex_id SUBSEP 1) )
        for (i=2; i<=_regexl; ++i ) _str = _str "|" juq( aobj_get(obj, _regex_id SUBSEP i) )
        _str = _str "]"
    }

    _cand_id = aobj_get_special_value_id( kp, "cand")
    _candl   = aobj_len(obj, _cand_id)
    if ( _candl > 0  ) {
        _str = _str " [candidate: "
        _str = _str aobj_get_cand_value(obj, _cand_id SUBSEP "\"1\"")
        if ( ( tag == "ARGS" ) || ( _candl < 6 ) ){
            for (i=2; i<=_candl; ++i ) _str = _str ", " aobj_get_cand_value(obj, _cand_id SUBSEP "\""i"\"")
        } else{
            for (i=2; i<=3; ++i ) _str = _str ", " aobj_get_cand_value(obj, _cand_id SUBSEP "\""i"\"")
            _kl = split( _cand_id, _cand_id_arr, SUBSEP )
            _k_id = juq(_cand_id_arr[ _kl - 2 ])
            split( _k_id, _k_id_arr, "|" )
            _str = _str " ...(Type '" _k_id_arr[1] "' for more candidate information)"
        }
        _str = _str "]"
    }
    return _str
}

function generate_optarg_rule_string(kp, option_id, tag,     _str, l, i) {
    l = aobj_get_optargc( obj, kp, option_id )
    _str = _str generate_optarg_rule_string_inner( kp SUBSEP option_id, tag)
    kp = kp SUBSEP option_id
    for (i=1; i<=l; ++i) _str = _str generate_optarg_rule_string_inner( kp SUBSEP "\"#"i"\"", tag)
    return _str
}

function generate_flag_help_unit( kp, arr, arr_kp,        i, v, l, _str, _max_len, _text_arr, _option_after ){
    arr_clone_of_kp( arr, _text_arr, arr_kp )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( kp, _text_arr )

    l = arr_len(arr, arr_kp)
    for ( i=1; i<=l; ++i ) {
        v = arr[ ( (arr_kp != "") ? arr_kp SUBSEP : arr_kp ) i ]
        _str = _str HELP_INDENT_STR sprintf("%s" DESC_INDENT_STR "%s\n",
            UI_THEME        str_pad_right(_text_arr[ i ], _max_len),
            UI_DESC         str_cut_line( aobj_get_description(obj, kp SUBSEP v), _max_len + HELP_INDENT_LEN + DESC_INDENT_LEN ) UI_END)
    }
    return _str
}

function generate_flag_help( kp, has_group,         _str, l, i, k ){
    _str = generate_title("FLAGS:")
    if (has_group == true) {
        l = FLAG_GROUP[ L ]
        for (i=1; i<=l; ++i){
            k = FLAG_GROUP[ i ]
            _str = _str "\n    -- " k " --\n" generate_flag_help_unit(kp, FLAG_GROUP, k)
        }
    } else _str = _str "\n" generate_flag_help_unit(kp, FLAG)
    return _str "\n"
}

function generate_option_help_unit( kp, arr, arr_kp,         i, v, l, _str, _max_len, _text_arr, _option_after ){
    arr_clone_of_kp( arr, _text_arr, arr_kp )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( kp, _text_arr )

    l = arr_len(arr, arr_kp)
    for ( i=1; i<=l; ++i ) {
        v = arr[ ( (arr_kp != "") ? arr_kp SUBSEP : arr_kp ) i ]
        _option_after = aobj_get_description(obj, kp SUBSEP v) UI_END generate_optarg_rule_string(kp, v, "OPTIONS")

        _str = _str HELP_INDENT_STR sprintf( "%s" DESC_INDENT_STR "%s\n",
            UI_THEME        str_pad_right(_text_arr[ i ], _max_len),
            UI_DESC         str_cut_line( _option_after, _max_len + HELP_INDENT_LEN + DESC_INDENT_LEN ) UI_END )
    }
    return _str
}

function generate_option_help( kp, has_group,            _str, l, i, k ) {
    _str = generate_title("OPTIONS:")
    if (has_group == true) {
        l = OPTION_GROUP[ L ]
        for (i=1; i<=l; ++i){
            k = OPTION_GROUP[ i ]
            _str = _str "\n    -- " k " --\n" generate_option_help_unit(kp, OPTION_GROUP, k)
        }
    } else _str = _str "\n" generate_option_help_unit(kp, OPTION)
    return _str "\n"
}

function generate_rest_argument_help( kp,         i, v, l, _str, _max_len, _text_arr, _option_after ){
    arr_clone_of_kp( RESTOPT, _text_arr )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( kp, _text_arr )

    _str = generate_title("ARGS:") "\n"
    l = arr_len(RESTOPT)
    for ( i=1; i<=l; ++i ) {
        v = RESTOPT[ i ]
        _option_after = aobj_get_description(obj, kp SUBSEP v) UI_END generate_optarg_rule_string(kp, v, "ARGS")

        _str = _str HELP_INDENT_STR sprintf( "%s" DESC_INDENT_STR "%s\n",
            UI_THEME        str_pad_right(_text_arr[ i ], _max_len),
            UI_DESC         str_cut_line( _option_after, _max_len + HELP_INDENT_LEN + DESC_INDENT_LEN ) UI_END)
    }
    return _str "\n"
}

function generate_subcmd_help_unit( kp, arr, arr_kp,        i, v, l, d, _str, _max_len, _option_after) {
    arr_clone_of_kp( arr, _text_arr, arr_kp )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( kp, _text_arr )

    l = arr_len(arr, arr_kp)
    for (i=1; i<=l; ++i) {
        v = arr[ ( (arr_kp != "") ? arr_kp SUBSEP : arr_kp ) i ]
        if ((d = aobj_get_description(obj, kp SUBSEP v)) == "") continue
        _option_after = d UI_END

        _str = _str HELP_INDENT_STR sprintf("%s"  DESC_INDENT_STR "%s\n",
            UI_THEME        str_pad_right(_text_arr[ i ], _max_len),
            UI_DESC         str_cut_line( _option_after, _max_len + HELP_INDENT_LEN + DESC_INDENT_LEN ) UI_END)
    }
    return _str
}

function generate_subcmd_help( kp, has_group,           _str, l, i, k) {
    _str = generate_title("SUBCOMMANDS:")
    if (has_group == true) {
        l = SUBCMD_GROUP[ L ]
        for (i=1; i<=l; ++i){
            k = SUBCMD_GROUP[ i ]
            _str = _str "\n    -- " k " --\n" generate_subcmd_help_unit(kp, SUBCMD_GROUP, k)
        }
    } else _str = _str "\n" generate_subcmd_help_unit(kp, SUBCMD)
    return _str "\nRun 'CMD SUBCOMMAND --help' for more information on a command\n\n"
}

function generate_name_help( obj, kp,       n, d, _str){
    if (aobj_is_null( obj, kp)) return
    _str = generate_title("NAME:") "\n"
    n = obj[ kp ]
    if ( n == "{" ) {
        n = obj[ kp, 1 ]
        if ((d = obj[ kp, n ]) == "null") d = get_value_with_local_language(obj, kp, WHICHNET)
    }
    _str = _str HELP_INDENT_STR  UI_THEME juq(n) UI_END ((d != "") ? " - " juq(d) : "" ) "\n"
    return _str "\n"
}

function generate_desc_help(obj, kp,        _str, d){
    if (aobj_is_null( obj, kp)) return
    _str =generate_title("DESCRIPTON:") "\n"
    d = obj[ kp ]
    if ( d == "{" ) d = get_value_with_local_language(obj, kp, WHICHNET)
    _str = _str HELP_INDENT_STR str_cut_line(juq(d), HELP_INDENT_LEN) "\n"
    return _str "\n"
}

function generate_synopsis_help(obj, kp,            l, i, k, v, _str) {
    if (aobj_is_null( obj, kp)) return
    _str = generate_title("SYNOPSIS:") "\n"
    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, jqu(i), 1]
        v = obj[ kp, jqu(i), k]
        if (v == "null") v = get_value_with_local_language(obj, kp SUBSEP jqu(i), WHICHNET)
        _str = _str HELP_INDENT_STR UI_THEME str_cut_line(juq(k) " " UI_END juq(v), HELP_INDENT_LEN) "\n"
    }
    return _str "\n"
}

function generate_tldr_help(obj, kp,            l, i, k, v, _str){
    if (aobj_is_null( obj, kp)) return
    _str = generate_title("EXAMPLES:") "\n"
    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, jqu(i), "\"cmd\"" ]
        v = get_value_with_local_language(obj, kp SUBSEP jqu(i), WHICHNET)
        if ((v != "") && (v != "null")) _str = _str HELP_INDENT_STR UI_THEME str_cut_line(juq(v), HELP_INDENT_LEN) "\n"
        _str = _str str_rep(" ", HELP_INDENT_LEN * 2) UI_END  str_cut_line(juq(k), HELP_INDENT_LEN * 2) "\n"
    }
    return _str "\n"
}

function generate_other_help(obj, kp,       l, i, k, v, _str){
    if (aobj_is_null( obj, kp)) return
    _str = generate_title("SEE ALSO:") "\n"
    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, i]
        v = obj[ kp, k]
        _str = _str HELP_INDENT_STR juq(k) UI_THEME " " juq(v) UI_END "\n"
    }
    return _str
}

function generate_tip_help_unit( arr, kp, color, title,            l, i, _str, v){
    l = arr[ kp L ]
    for (i=1; i<=l; ++i) {
        if ( (v = arr[ kp, "\""i"\"" ]) == "{" ) v = get_value_with_local_language(arr, kp SUBSEP "\""i"\"", WHICHNET)
        _str = _str HELP_INDENT_STR UI_TITLE color title "\n" UI_END HELP_INDENT_STR HELP_INDENT_STR  str_cut_line(juq( v ), HELP_INDENT_LEN * 2) UI_END "\n"
    }
    return _str
}
function generate_tip_help(arr,         _str, i, l, kp, color, title){
    l = arr[ L ]
    for (i=1; i<=l; ++i) {
        kp = arr[i]
        if ( kp == "#tip" )               { color = UI_TIP_INFO  ; title = "TIP:"; }
        else if ( kp == "#tip:note" )     { color = UI_TIP_NOTE  ; title = "NOTE:"; }
        else if ( kp == "#tip:warn" )     { color = UI_TIP_WARN  ; title = "WARNING:"; }
        else if ( kp == "#tip:danger" )   { color = UI_TIP_DANGER; title = "DANGER:"; }
        _str = _str generate_tip_help_unit(arr, kp, color, title)
    }
    return _str
}

function help_get_ref(obj, kp,        r, filepath){
    if ( (r = jref_get(obj, kp) ) != false ) {
        jref_replace_with_empty_dict(obj, kp)
        filepath = ___X_CMD_ROOT_MOD "/" juq(r)
        jqparse_dict0( cat( filepath ), obj, kp )
    }
}

function print_helpdoc( obj, kp,          i, j, l, v, _str, s, k ){
    help_get_ref(obj, kp)
    l = aobj_len( obj, kp )
    for (i=1; i<=l; ++i) {
        v = aobj_get( obj, kp SUBSEP i)
        s = juq(v)
        if ( s == "#name")              IS_NAME = true
        else if ( s == "#desc")         IS_DESCRIPTION = true
        else if ( s == "#synopsis")     IS_SYNOPSIS = true
        else if ( s == "#tldr")         IS_TLDR = true
        else if ( s == "#other")        IS_OTHER = true
        else if ( s ~ "^#tip" ) {
            HAS_TIP = true
            arr_push(TIP, s)
            cp_cover(TIP, s, obj, kp SUBSEP v)
        }
        else if ( match(s, "^#subcmd:") ) {
            HAS_SUBCMD_GROUP = true
            k = substr( s, RLENGTH + 1 )
            arr_push( SUBCMD_GROUP, k )
            SUBCMD_GROUP[ k L ] = jlist_value2arr(obj, kp SUBSEP v, "", SUBCMD_GROUP, k SUBSEP)
        }
        else if ( match(s, "^#option:") ) {
            HAS_OPTION_GROUP = true
            k = substr( s, RLENGTH + 1 )
            arr_push( OPTION_GROUP, k )
            OPTION_GROUP[ k L ] = jlist_value2arr(obj, kp SUBSEP v, "", OPTION_GROUP, k SUBSEP)
        }
        else if ( match(s, "^#flag:") ) {
            HAS_FLAG_GROUP = true
            k = substr( s, RLENGTH + 1 )
            arr_push( FLAG_GROUP, k )
            FLAG_GROUP[ k L ] = jlist_value2arr(obj, kp SUBSEP v, "", FLAG_GROUP, k SUBSEP)
        }
        else if (( s ~ "^-" ) && ( ! aobj_istrue(obj, aobj_get_special_value_id(kp SUBSEP v, "SUBCMD")) )) {
            if (aobj_get_optargc( obj, kp, v ) > 0) arr_push( OPTION, v)
            else arr_push( FLAG, v )
        }
        else if ( s ~ "^#(([0-9]+)|n)$" ) arr_push( RESTOPT, v )
        else if ( s !~ "^#" ) arr_push( SUBCMD, v )
    }

    if ( IS_NAME == true )                                  printf("%s", generate_name_help( obj, kp SUBSEP "\"#name\""))
    if ( IS_SYNOPSIS == true )                              printf("%s", generate_synopsis_help( obj, kp SUBSEP "\"#synopsis\""))
    if ( IS_DESCRIPTION == true )                           printf("%s", generate_desc_help( obj, kp SUBSEP "\"#desc\""))
    if ( HAS_TIP == true )                                  printf("%s", generate_tip_help(TIP))
    if (0 != arr_len(OPTION))                               printf("%s", generate_option_help( kp, HAS_OPTION_GROUP ))
    if (0 != arr_len(FLAG))                                 printf("%s", generate_flag_help( kp, HAS_FLAG_GROUP ))
    if (0 != arr_len(RESTOPT))                              printf("%s", generate_rest_argument_help( kp ))
    if (0 != arr_len(SUBCMD))                               printf("%s", generate_subcmd_help( kp, HAS_SUBCMD_GROUP ))
    if ( IS_TLDR == true )                                  printf("%s", generate_tldr_help( obj, kp SUBSEP "\"#tldr\""))
    if ( IS_OTHER == true )                                 printf("%s", generate_other_help( obj, kp SUBSEP "\"#other\""))
}
