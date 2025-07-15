function print_helpdoc_init(no_color, name_color, desc_color, title_color, rule_color, cmd_color, other_name_color, other_desc_color, tldr_cmd_color, tldr_desc_color, position_order, po_arr ){
    COMP_HELPDOC_HELP_INDENT_LEN = 4;    COMP_HELPDOC_HELP_INDENT_STR = "    "
    COMP_HELPDOC_DESC_INDENT_LEN = 3;    COMP_HELPDOC_DESC_INDENT_STR = "   "
    COMP_HELPDOC_TAG_LEFT = "---- "
    COMP_HELPDOC_TAG_RIGHT = " ----"
    if (no_color != true ) {
        COMP_HELPDOC_UI_TIP_INFO   = UI_FG_GREEN
        COMP_HELPDOC_UI_TIP_NOTE   = UI_FG_CYAN
        COMP_HELPDOC_UI_TIP_WARN   = UI_FG_YELLOW
        COMP_HELPDOC_UI_TIP_DANGER = UI_FG_RED

        COMP_HELPDOC_UI_END        = UI_END

        COMP_HELPDOC_UI_DESC       = desc_color     # UI_FG_BRIGHT_RED
        COMP_HELPDOC_UI_NAME       = name_color    # UI_FG_CYAN
        COMP_HELPDOC_UI_TITLE      = title_color    # UI_TEXT_BOLD
        COMP_HELPDOC_UI_RULE       = rule_color    # UI_FG_BRIGHT_BLACK
        COMP_HELPDOC_UI_CMD        = ( cmd_color == "" ) ? name_color : cmd_color
        COMP_HELPDOC_UI_OTHER_NAME = other_name_color
        COMP_HELPDOC_UI_OTHER_DESC = other_desc_color
        COMP_HELPDOC_UI_TLDR_CMD    = tldr_cmd_color
        COMP_HELPDOC_UI_TLDR_DESC   = tldr_desc_color
    }

    comp_parse_position_order( position_order, po_arr)
}

function str_cut_line( str, indent, width,        o, kp, _next_line, _res, i, l ){
    if ( COMP_HELPDOC_WIDTH < indent )     return str
    kp = "UTF8TT"
    utf8tt_init(str, o, kp)
    utf8tt_refresh(o, kp, "", ((width == "") ? COMP_HELPDOC_WIDTH - indent : width))
    _next_line = "\n" space_rep(indent)
    _res = o[kp, "VIEW", 1]
    l = o[kp, "VIEW" L]
    for (i=2; i<=l; ++i) _res = _res _next_line o[kp, "VIEW", i]
    return _res
}

function cut_line2obj( o, kp, str, width ){
    utf8tt_init(str, o, kp)
    utf8tt_refresh(o, kp, "", width)
}

# left_str, left_width, left_indent
function comp_helpdoc_unit_line(ls, lw, li, rs, rw, ri,     o, _right_indent, _res, i, ll, rl){
    cut_line2obj(o, "left", ls, lw)
    cut_line2obj(o, "right", rs, rw)
    ll = o[ "left", "VIEW" L ]
    rl = o[ "right", "VIEW" L ]
    _right_indent = space_rep(li + lw + ri)
    li = space_rep(li)
    ri = space_rep(ri)
    for (i=1; i<=ll; ++i) _res = ((_res == "") ? "" : _res "\n") li o[ "left", "VIEW", i ] ri  COMP_HELPDOC_UI_END o[ "right", "VIEW", i ] COMP_HELPDOC_UI_END
    for (; i<=rl; ++i) _res = _res "\n" _right_indent o[ "right", "VIEW", i ]
    return _res
}

function generate___cmd_doc_str( obj, kp, v,         _str, _synopsis_str){
    _str = juq(v)
    # gsub("\\|", ",", _str)
    _synopsis_str = aobj_get_special_value(obj, kp SUBSEP v, "synopsis")
    if ( (! aobj_str_is_null(_synopsis_str)) && (_synopsis_str != "[")) _str = _str " " aobj_uq( _synopsis_str )
    return _str
}

function generate___title(v){ return COMP_HELPDOC_UI_TITLE v COMP_HELPDOC_UI_END ;  }
function generate___tag(v){ return COMP_HELPDOC_TAG_LEFT v COMP_HELPDOC_TAG_RIGHT; }
function generate___parse_cmd_doc( obj, kp, arr_group,        l, i, _cmd_doc, _len, _idx, _max_len){
    l = arr_group[ L ]
    for (i=0; i<=l; ++i){
        k = arr_group[ i ]
        if (ADVISE_DEV_TAG[ SUBSEP k ]) continue

        _jl = aobj_len( arr_group, k )
        if (_jl <= 0) continue
        for (j=1; j<=_jl; ++j) {
            _cmd_doc = generate___cmd_doc_str( obj, kp, arr_group[ k, "\""j"\"" ] )
            _len = length( _cmd_doc )
            if ( (_idx = index( _cmd_doc, " " )) <= 0 ) arr_group[ k, "\""j"\"", "cmd_doc" ] = _cmd_doc
            else arr_group[ k, "\""j"\"", "cmd_doc" ] = substr( _cmd_doc, 1, _idx - 1 ) COMP_HELPDOC_UI_END COMP_HELPDOC_UI_RULE substr( _cmd_doc, _idx ) COMP_HELPDOC_UI_END

            if ( _len > _max_len ) _max_len = _len
        }
    }

    arr_group[ "max_width_len" ] = _max_len
}

function generate___ret_optarg_rule_string_inner(obj, kp, tag,          _str, _dafault, _regexl, _candl, i, _cand_id_arr){
    _default = aobj_get_default(obj, kp)
    if (_default != "" ) _str = _str "\n" COMP_HELPDOC_UI_RULE " [default: " aobj_uq(_default) "]" COMP_HELPDOC_UI_END

    _regex_id = aobj_get_special_value_id( kp, "regex")
    _regexl  = aobj_len(obj, _regex_id)
    if ( _regexl > 0 ) {
        _str = _str "\n" COMP_HELPDOC_UI_RULE " [regex: "
        _str = _str juq( aobj_get(obj, _regex_id SUBSEP 1) )
        for (i=2; i<=_regexl; ++i ) _str = _str "|" juq( aobj_get(obj, _regex_id SUBSEP i) )
        _str = _str "]" COMP_HELPDOC_UI_END
    }

    _cand_id = aobj_get_special_value_id( kp, "cand")
    _candl   = aobj_len(obj, _cand_id)
    if ( _candl > 0  ) {
        _str = _str "\n" COMP_HELPDOC_UI_RULE " [candidate: "
        _str = _str aobj_get_cand_value(obj, _cand_id SUBSEP "\"1\"")
        if ( ( tag == "ARGS" ) || ( _candl < 50 ) ){
            for (i=2; i<=_candl; ++i ) _str = _str ", " aobj_get_cand_value(obj, _cand_id SUBSEP "\""i"\"")
        } else{
            for (i=2; i<=49; ++i ) _str = _str ", " aobj_get_cand_value(obj, _cand_id SUBSEP "\""i"\"")
            _str = _str " ..."
        }
        _str = _str "]" COMP_HELPDOC_UI_END
    }
    return _str
}

function generate___ret_optarg_rule_string(obj, kp, option_id, tag,     _str, l, i) {
    l = aobj_get_optargc( obj, kp, option_id )
    _str = generate___ret_optarg_rule_string_inner(obj, kp SUBSEP option_id, tag)
    kp = kp SUBSEP option_id
    for (i=1; i<=l; ++i) _str = _str generate___ret_optarg_rule_string_inner(obj, kp SUBSEP "\"#"i"\"", tag)
    return _str
}

function generate_flag_help_unit( obj, kp, arr_group, arr_kp,        i, v, l, _str, _max_len, _str_cmd_desc ){
    _max_len = arr_group[ "max_width_len" ]
    l = arr_len(arr_group, arr_kp)
    for ( i=1; i<=l; ++i ) {
        v = arr_group[ arr_kp SUBSEP "\""i"\"" ]
        if (obj[ kp, v ] == "") continue
        _str_cmd_desc = COMP_HELPDOC_UI_DESC aobj_get_description(obj, kp SUBSEP v) COMP_HELPDOC_UI_END
        _str = _str comp_helpdoc_unit_line( COMP_HELPDOC_UI_NAME arr_group[ arr_kp, "\""i"\"", "cmd_doc" ], _max_len, COMP_HELPDOC_HELP_INDENT_LEN, \
            _str_cmd_desc, COMP_HELPDOC_WIDTH - _max_len - COMP_HELPDOC_HELP_INDENT_LEN - COMP_HELPDOC_DESC_INDENT_LEN, COMP_HELPDOC_DESC_INDENT_LEN ) "\n"
    }
    return _str
}

function generate_flag_help(obj, kp, arr_group,        _str, _str_unit, l, i, k ){
    if (! arr_group[ ADVISE_HAS_TAG ]) return
    generate___parse_cmd_doc( obj, kp, arr_group )
    l = arr_group[ L ]
    for (i=0; i<=l; ++i){
        k = arr_group[ i ]
        if (ADVISE_DEV_TAG[ SUBSEP k ]) continue
        if (! aobj_len( arr_group, k )) continue
        _str_unit = generate_flag_help_unit(obj, kp, arr_group, k)
        if ( _str_unit != "" ) {
            if ( k == ADVISE_NULL_TAG ) _str = _str _str_unit
            else _str = _str "    " generate___tag(juq(k)) "\n" _str_unit
        }
    }
    if (_str == "") return
    return generate___title("FLAGS:") "\n" _str
}

function generate_option_help_unit( obj, kp, arr_group, arr_kp,         i, v, l, _str, _max_len, _str_cmd_desc ){
    _max_len = arr_group[ "max_width_len" ]
    l = arr_len(arr_group, arr_kp)
    for ( i=1; i<=l; ++i ) {
        v = arr_group[ arr_kp SUBSEP "\""i"\"" ]
        if (obj[ kp, v ] == "") continue
        _str_cmd_desc = COMP_HELPDOC_UI_DESC aobj_get_description(obj, kp SUBSEP v) COMP_HELPDOC_UI_END generate___ret_optarg_rule_string(obj, kp, v, "OPTIONS")
        _str = _str comp_helpdoc_unit_line( COMP_HELPDOC_UI_NAME arr_group[ arr_kp, "\""i"\"", "cmd_doc" ], _max_len, COMP_HELPDOC_HELP_INDENT_LEN, \
            _str_cmd_desc, COMP_HELPDOC_WIDTH - _max_len - COMP_HELPDOC_HELP_INDENT_LEN - COMP_HELPDOC_DESC_INDENT_LEN, COMP_HELPDOC_DESC_INDENT_LEN ) "\n"
    }
    return (_str != "") ? _str "\n" : ""
}

function generate_option_help( obj, kp, arr_group,           _str, _str_unit, l, i, k ) {
    if (! arr_group[ ADVISE_HAS_TAG ]) return
    generate___parse_cmd_doc( obj, kp, arr_group )
    l = arr_group[ L ]
    for (i=0; i<=l; ++i){
        k = arr_group[ i ]
        if (ADVISE_DEV_TAG[ SUBSEP k ]) continue
        if (! aobj_len( arr_group, k )) continue
        _str_unit = generate_option_help_unit( obj, kp, arr_group, k)
        if ( _str_unit != "" ) {
            if ( k == ADVISE_NULL_TAG ) _str = _str _str_unit
            else _str = _str "    " generate___tag(juq(k)) "\n" _str_unit
        }
    }
    if (_str == "") return
    return generate___title("OPTIONS:") "\n" _str
}

function generate_rest_argument_help( obj, kp, arr_group,         i, v, l, arr_kp, _str, _max_len, _str_cmd_desc ){
    if (! arr_group[ ADVISE_HAS_TAG ]) return
    generate___parse_cmd_doc( obj, kp, arr_group )
    _max_len = arr_group[ "max_width_len" ]

    arr_kp = ADVISE_NULL_TAG
    l = arr_len(arr_group, arr_kp)
    for ( i=1; i<=l; ++i ) {
        v = arr_group[ arr_kp SUBSEP "\""i"\"" ]
        help_get_ref(obj, kp SUBSEP v)
        _str_cmd_desc = COMP_HELPDOC_UI_DESC aobj_get_description(obj, kp SUBSEP v) COMP_HELPDOC_UI_END generate___ret_optarg_rule_string(obj, kp, v, "ARGS")
        if (str_remove_esc(_str_cmd_desc) == "") continue
        _str = _str comp_helpdoc_unit_line( COMP_HELPDOC_UI_NAME arr_group[ arr_kp, "\""i"\"", "cmd_doc" ], _max_len, COMP_HELPDOC_HELP_INDENT_LEN, \
            COMP_HELPDOC_UI_DESC _str_cmd_desc, COMP_HELPDOC_WIDTH - _max_len - COMP_HELPDOC_HELP_INDENT_LEN - COMP_HELPDOC_DESC_INDENT_LEN, COMP_HELPDOC_DESC_INDENT_LEN ) "\n"
    }
    if (_str == "") return
    return generate___title("ARGS:") "\n" _str "\n"
}

function generate_subcmd_help_unit( obj, kp, arr_group, arr_kp,        i, v, l, _str, _max_len, _str_cmd_desc){
    _max_len = arr_group[ "max_width_len" ]
    l = arr_len(arr_group, arr_kp)
    for (i=1; i<=l; ++i) {
        v = arr_group[ arr_kp SUBSEP "\""i"\"" ]
        if (obj[ kp, v ] == "") continue
        _str_cmd_desc = COMP_HELPDOC_UI_DESC aobj_get_description(obj, kp SUBSEP v) COMP_HELPDOC_UI_END
        _str = _str comp_helpdoc_unit_line( COMP_HELPDOC_UI_NAME arr_group[ arr_kp, "\""i"\"", "cmd_doc" ], _max_len, COMP_HELPDOC_HELP_INDENT_LEN, \
            _str_cmd_desc, COMP_HELPDOC_WIDTH - _max_len - COMP_HELPDOC_HELP_INDENT_LEN - COMP_HELPDOC_DESC_INDENT_LEN, COMP_HELPDOC_DESC_INDENT_LEN ) "\n"
    }

    return _str
}
function generate_subcmd_help( obj, kp, arr_group,          _str, _str_title, _str_footer, _str_unit, l, i, k){
    if (! arr_group[ ADVISE_HAS_TAG ]) return
    generate___parse_cmd_doc( obj, kp, arr_group )
    l = arr_group[ L ]
    for (i=0; i<=l; ++i){
        k = arr_group[ i ]
        if (ADVISE_DEV_TAG[ SUBSEP k ]) continue
        if (! aobj_len( arr_group, k )) continue
        _str_unit = generate_subcmd_help_unit( obj, kp, arr_group, k)
        if ( _str_unit != "" ) {
            if ( k == ADVISE_NULL_TAG ) _str = _str _str_unit
            else _str = _str "    " generate___tag(juq(k)) "\n" _str_unit
        }
    }

    _str_title = generate___title("SUBCOMMANDS:") "\n"
    _str_footer = generate_subcmd_help_tip( obj, kp )
    if (_str != "") return _str_title _str "\n" _str_footer
}

function generate_subcmd_help_tip( obj, kp,          _res, i, l, arr, k, _id){
    if ( obj[ kp, "\"#subcmd_help_tip\"" ] != "true" ) return
    _res = "CMD "
    if (kp ~ "^DATA") _id = 3
    else _id = 2
    l = split( kp, arr, SUBSEP )
    kp = substr( kp, 1, index(kp, arr[ _id ])-1)
    if ((_name = juq(obj[ kp arr[ _id ], jqu("#name"), 1 ])) != "") {
        gsub( "\\|.*$", "", _name )
        if ( _name != "x" ) _res = "x " _name " "
        else _res = "x "
    }
    for (i=_id+1; i<=l; ++i){
        k = juq(arr[i])
        gsub( "\\|.*$", "", k )
        _res = _res k " "
    }
    _res = _res "<SUBCOMMAND> --help"
    if (___X_CMD_LANG == "\"cn\"") return "运行 '"_res"' 以获取有关命令的更多信息\n\n"
    return "Run '"_res"' for more information on a command\n\n"
}

function generate_name_help( obj, kp,       n, d, _str){
    kp = kp SUBSEP "\"#name\""
    if (aobj_is_null( obj, kp)) return
    _str = generate___title("NAME:") "\n"
    n = obj[ kp ]
    if ( n == "{" ) {
        n = obj[ kp, 1 ]
        if ((d = obj[ kp, n ]) == "null") d = aobj_get_value_with_local_language(obj, kp, ___X_CMD_LANG)
    }
    _str = _str COMP_HELPDOC_HELP_INDENT_STR COMP_HELPDOC_UI_CMD juq(n) COMP_HELPDOC_UI_END ( aobj_str_is_null(d) ? "" : " - " aobj_uq(d) ) "\n"
    return _str "\n"
}

function generate_desc_help(obj, kp, tip,        _str, d, tip_str){
    kp = kp SUBSEP "\"#desc\""
    tip_str = generate_tip_help(tip)
    if (! aobj_is_null( obj, kp) ) {
        d = obj[ kp ]
        if ( d == "{" ) d = aobj_get_value_with_local_language(obj, kp, ___X_CMD_LANG)
        _str = COMP_HELPDOC_HELP_INDENT_STR str_cut_line(aobj_uq(d), COMP_HELPDOC_HELP_INDENT_LEN) "\n"
    }
    _str = (_str != "") ? _str "\n" tip_str : tip_str
    return (_str != "") ? generate___title("DESCRIPTON:") "\n" _str : ""
}

function generate_synopsis_help(obj, kp,            l, i, k, v, _str) {
    kp = kp SUBSEP "\"#synopsis\""
    if (aobj_is_null( obj, kp)) return
    _str = generate___title("SYNOPSIS:") "\n"
    v = obj[ kp ]
    if ( (v != "[") && (v != "") )
        return _str COMP_HELPDOC_HELP_INDENT_STR th( COMP_HELPDOC_UI_NAME, aobj_uq(v) ) "\n\n"

    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, jqu(i), 1]
        v = obj[ kp, jqu(i), k]
        if (v == "null") v = aobj_get_value_with_local_language(obj, kp SUBSEP jqu(i), ___X_CMD_LANG)
        _str = _str COMP_HELPDOC_HELP_INDENT_STR str_cut_line( COMP_HELPDOC_UI_NAME juq(k) " " COMP_HELPDOC_UI_END aobj_uq(v), COMP_HELPDOC_HELP_INDENT_LEN) "\n"
    }
    return _str "\n"
}

function generate_tldr_help(obj, kp,            l, i, k, v, _str){
    kp = kp SUBSEP "\"#tldr\""
    if (aobj_is_null( obj, kp)) return
    _str = generate___title("TLDR:") "\n"
    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, jqu(i), "\"cmd\"" ]
        v = aobj_get_value_with_local_language(obj, kp SUBSEP jqu(i), ___X_CMD_LANG)
        if ( ! aobj_str_is_null(v) ) _str = _str COMP_HELPDOC_HELP_INDENT_STR str_cut_line(COMP_HELPDOC_UI_TLDR_DESC aobj_uq(v) COMP_HELPDOC_UI_END, COMP_HELPDOC_HELP_INDENT_LEN) "\n"
        _str = _str space_rep(COMP_HELPDOC_HELP_INDENT_LEN * 2) COMP_HELPDOC_UI_TLDR_CMD str_cut_line(aobj_uq(k) COMP_HELPDOC_UI_END, COMP_HELPDOC_HELP_INDENT_LEN * 2) "\n"
    }
    return _str "\n"
}

function generate_other_help_unit(obj, kp,      l, i, k, v, _str, _kp_language){
    _kp_language = aobj_get_kp_with_local_language(obj, kp, ___X_CMD_LANG)
    if ( ! aobj_is_null(obj, _kp_language) ) return generate_other_help_unit(obj, _kp_language)
    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, i]
        v = obj[ kp, k]
        _str = _str COMP_HELPDOC_UI_OTHER_NAME COMP_HELPDOC_HELP_INDENT_STR juq(k) COMP_HELPDOC_UI_OTHER_DESC " " aobj_uq(v) COMP_HELPDOC_UI_END "\n"
    }
    return _str
}

function generate_other_help(obj, kp,       l, i, k, v, _str){
    kp = kp SUBSEP "\"#other\""
    if (aobj_is_null( obj, kp)) return
    return generate___title("SEE ALSO:") "\n" generate_other_help_unit(obj, kp)
}

function generate_tip_help_unit( arr, kp, color, title,            l, i, _str, v){
    l = arr[ kp L ]
    for (i=1; i<=l; ++i) {
        if ( (v = arr[ kp, "\""i"\"" ]) == "{" ) v = aobj_uq(aobj_get_value_with_local_language(arr, kp SUBSEP "\""i"\"", ___X_CMD_LANG))
        sub("\n+$", "", v)
        _str = _str COMP_HELPDOC_HELP_INDENT_STR COMP_HELPDOC_UI_TITLE color title "\n" COMP_HELPDOC_UI_END COMP_HELPDOC_HELP_INDENT_STR COMP_HELPDOC_HELP_INDENT_STR  str_cut_line( v, COMP_HELPDOC_HELP_INDENT_LEN * 2) COMP_HELPDOC_UI_END "\n"
    }
    return _str
}
function generate_tip_help(arr,         _str, i, l, kp, color, title){
    l = arr[ L ]
    for (i=1; i<=l; ++i) {
        kp = arr[i]
        if ( kp == "#tip" )               { color = COMP_HELPDOC_UI_TIP_INFO  ; title = "TIP:"; }
        else if ( kp == "#tip:note" )     { color = COMP_HELPDOC_UI_TIP_NOTE  ; title = "NOTE:"; }
        else if ( kp == "#tip:warn" )     { color = COMP_HELPDOC_UI_TIP_WARN  ; title = "WARNING:"; }
        else if ( kp == "#tip:danger" )   { color = COMP_HELPDOC_UI_TIP_DANGER; title = "DANGER:"; }
        _str = _str generate_tip_help_unit(arr, kp, color, title)
    }
    return (_str != "" ) ? _str "\n" : ""
}

function help_get_ref(obj, kp,        msg){
    if ((msg = comp_advise_get_ref(obj, kp)) != true) return false # panic( msg )
}

function comp_parse_position_order(str, arr,        i, l){
    sub("^[-]+", "", str)
    if (str == "") str = "name,synopsis,desc,tldr,option,flag,arg,subcmd,other"
    return arr_cut( arr, str, "," )
}

function print_helpdoc( obj, kp, width, po_arr,             _res, i, j, l, v, s, TIP, RESTOPT, OPTION_GROUP, SUBCMD_GROUP, FLAG_GROUP ){
    if (width < 20) return "The current width is not enough to display the help document!\n"
    COMP_HELPDOC_WIDTH = width
    COMP_HELPDOC_LEFT_W = int(width/5) * 3
    # if (COMP_HELPDOC_LEFT_W > 30) COMP_HELPDOC_LEFT_W = 30
    help_get_ref(obj, kp)
    l = aobj_len( obj, kp )
    for (i=1; i<=l; ++i) {
        v = aobj_get( obj, kp SUBSEP i)
        s = juq(v)
        if ( s ~ "^#tip" ) {
            arr_push(TIP, s)
            cp_cover(TIP, s, obj, kp SUBSEP v)
        }
        else if ( s ~ "^#(([0-9]+)|n)$" ) comp_advise_push_group_of_value( obj, kp, RESTOPT, ADVISE_NULL_TAG, v )
    }

    comp_advise_parse_group(obj, kp, SUBCMD_GROUP, OPTION_GROUP, FLAG_GROUP)
    l = po_arr[L]
    for (i=1; i<=l; ++i){
        v = po_arr[i]
        if (v == "name")            _res = _res generate_name_help( obj, kp )
        else if (v == "synopsis")   _res = _res generate_synopsis_help( obj, kp )
        else if (v == "desc")       _res = _res generate_desc_help( obj, kp, TIP )
        else if (v == "option")     _res = _res generate_option_help( obj, kp, OPTION_GROUP )
        else if (v == "flag")       _res = _res generate_flag_help( obj, kp, FLAG_GROUP )
        else if (v == "arg")        _res = _res generate_rest_argument_help( obj, kp, RESTOPT )
        else if (v == "subcmd")     _res = _res generate_subcmd_help( obj, kp, SUBCMD_GROUP )
        else if (v == "tldr")       _res = _res generate_tldr_help( obj, kp )
        else if (v == "other")      _res = _res generate_other_help( obj, kp )
    }

    gsub("\n+$", "\n", _res)
    return _res
}
