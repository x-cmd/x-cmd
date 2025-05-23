function print_helpdoc_init(no_color, theme_color0, theme_color1, desc_color0, desc_color1, position_order, po_arr ){
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

        COMP_HELPDOC_UI_TITLE      = UI_TEXT_BOLD
        COMP_HELPDOC_UI_DESC[0]    = ( desc_color0 == "" ) ? UI_FG_DARKRED : desc_color0
        COMP_HELPDOC_UI_DESC[1]    = ( desc_color1 == "" ) ? UI_FG_DARKRED : desc_color1 # UI_FG_MAGENTA
        COMP_HELPDOC_UI_THEME[0]   = ( theme_color0 == "" ) ? UI_FG_CYAN  : theme_color0
        COMP_HELPDOC_UI_THEME[1]   = ( theme_color1 == "" ) ? UI_FG_CYAN : theme_color1 # UI_FG_GREEN
    }

    comp_parse_position_order( position_order, po_arr)
}

function arr_clone_of_kp( src, dst, kp,       l, i ){
    dst[ L ] = l = src[ kp L ]
    for (i=1; i<=l; ++i)  dst[i] = src[ (kp != "") ? kp SUBSEP "\""i"\"" : i ]
    return l
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

function get_option_string( obj, kp, v,         _str, _synopsis_str){
    _str = juq(v)
    # gsub("\\|", ",", _str)
    _synopsis_str = aobj_get_special_value(obj, kp SUBSEP v, "synopsis")
    if ( (! aobj_str_is_null(_synopsis_str)) && (_synopsis_str != "[")) _str = _str " " aobj_uq( _synopsis_str )
    return _str
}

function generate_title(v){ return COMP_HELPDOC_UI_TITLE v COMP_HELPDOC_UI_END ;  }
function generate_help_for_namedoot_cal_maxlen_desc( obj, kp, _text_arr,            l, i, _len, _max_len, _opt_help_doc ){
    l = arr_len(_text_arr)
    for ( i=1; i<=l; ++i ) {
        _text_arr[ i ]   = _opt_help_doc     = get_option_string( obj, kp, _text_arr[ i ] )
        _len = length( _opt_help_doc )        # TODO: Might using wcswidth
        if ( _len > _max_len )    _max_len = _len
    }
    return (_max_len <= COMP_HELPDOC_LEFT_W) ? _max_len : COMP_HELPDOC_LEFT_W
}

function generate_optarg_rule_string_inner(obj, kp, tag,          _str, _dafault, _regexl, _candl, i, _cand_id_arr){
    _default = aobj_get_default(obj, kp)
    if (_default != "" ) _str = _str " [default: " aobj_uq(_default) "]"

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
            for (i=2; i<=5; ++i ) _str = _str ", " aobj_get_cand_value(obj, _cand_id SUBSEP "\""i"\"")
            _str = _str " ..."
        }
        _str = _str "]"
    }
    return _str
}

function generate_optarg_rule_string(obj, kp, option_id, tag,     _str, l, i) {
    l = aobj_get_optargc( obj, kp, option_id )
    _str = generate_optarg_rule_string_inner(obj, kp SUBSEP option_id, tag)
    kp = kp SUBSEP option_id
    for (i=1; i<=l; ++i) _str = _str generate_optarg_rule_string_inner(obj, kp SUBSEP "\"#"i"\"", tag)
    return _str
}

function generate_flag_help_unit( obj, kp, arr, arr_kp,        i, v, l, _str, _max_len, _text_arr, _option_after ){
    arr_clone_of_kp( arr, _text_arr, arr_kp )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( obj, kp, _text_arr )

    th_interval_init(COMP_HELPDOC_UI_THEME)
    th_interval_init(COMP_HELPDOC_UI_DESC)
    l = arr_len(arr, arr_kp)
    for ( i=1; i<=l; ++i ) {
        v = arr[ arr_kp SUBSEP "\""i"\"" ]
        if (obj[ kp, v ] == "") continue
        _option_after = aobj_get_description(obj, kp SUBSEP v)
        _str = _str comp_helpdoc_unit_line( th_interval(COMP_HELPDOC_UI_THEME) _text_arr[i], _max_len, COMP_HELPDOC_HELP_INDENT_LEN, \
            th_interval(COMP_HELPDOC_UI_DESC) _option_after, COMP_HELPDOC_WIDTH - _max_len - COMP_HELPDOC_HELP_INDENT_LEN - COMP_HELPDOC_DESC_INDENT_LEN, COMP_HELPDOC_DESC_INDENT_LEN ) "\n"
    }
    return _str
}

function generate_flag_help(obj, kp, arr_group,        _str, l, i, k ){
    if (! arr_group[ ADVISE_HAS_TAG ]) return
    if (arr_len(arr_group, ADVISE_NULL_TAG)) _str = generate_flag_help_unit(obj, kp, arr_group, ADVISE_NULL_TAG ) "\n"
    l = arr_group[ L ]
    for (i=1; i<=l; ++i){
        k = arr_group[ i ]
        if (ADVISE_DEV_TAG[ SUBSEP k ]) continue
        if (! aobj_len( arr_group, k )) continue
        _str = _str "    " COMP_HELPDOC_TAG_LEFT juq(k) COMP_HELPDOC_TAG_RIGHT "\n" generate_flag_help_unit(obj, kp, arr_group, k) "\n"
    }
    if (_str == "") return
    return generate_title("FLAGS:") "\n" _str
}

function generate_option_help_unit( obj, kp, arr, arr_kp,         i, v, l, _str, _max_len, _text_arr, _option_after ){
    arr_clone_of_kp( arr, _text_arr, arr_kp )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( obj, kp, _text_arr )

    th_interval_init(COMP_HELPDOC_UI_THEME)
    th_interval_init(COMP_HELPDOC_UI_DESC)
    l = arr_len(arr, arr_kp)
    for ( i=1; i<=l; ++i ) {
        v = arr[ arr_kp SUBSEP "\""i"\"" ]
        if (obj[ kp, v ] == "") continue
        _option_after = aobj_get_description(obj, kp SUBSEP v) COMP_HELPDOC_UI_END generate_optarg_rule_string(obj, kp, v, "OPTIONS")
        _str = _str comp_helpdoc_unit_line( th_interval(COMP_HELPDOC_UI_THEME) _text_arr[i], _max_len, COMP_HELPDOC_HELP_INDENT_LEN, \
            th_interval(COMP_HELPDOC_UI_DESC) _option_after, COMP_HELPDOC_WIDTH - _max_len - COMP_HELPDOC_HELP_INDENT_LEN - COMP_HELPDOC_DESC_INDENT_LEN, COMP_HELPDOC_DESC_INDENT_LEN ) "\n"
    }
    return (_str != "") ? _str "\n" : ""
}

function generate_option_help( obj, kp, arr_group,           _str, l, i, k ) {
    if (! arr_group[ ADVISE_HAS_TAG ]) return
    if (arr_len(arr_group, ADVISE_NULL_TAG)) _str = generate_option_help_unit( obj, kp, arr_group, ADVISE_NULL_TAG)
    l = arr_group[ L ]
    for (i=1; i<=l; ++i){
        k = arr_group[ i ]
        if (ADVISE_DEV_TAG[ SUBSEP k ]) continue
        if (! aobj_len( arr_group, k )) continue
        _str = _str "    " COMP_HELPDOC_TAG_LEFT juq(k) COMP_HELPDOC_TAG_RIGHT "\n" generate_option_help_unit( obj, kp, arr_group, k)
    }
    if (_str == "") return
    return generate_title("OPTIONS:") "\n" _str
}

function generate_rest_argument_help( obj, kp, arr,         i, v, l, _str, _max_len, _text_arr, _option_after ){
    if ((l = arr_len(arr)) <= 0) return
    arr_clone_of_kp( arr, _text_arr )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( obj, kp, _text_arr )

    th_interval_init(COMP_HELPDOC_UI_THEME)
    th_interval_init(COMP_HELPDOC_UI_DESC)
    for ( i=1; i<=l; ++i ) {
        v = arr[ i ]
        help_get_ref(obj, kp SUBSEP v)
        if (str_remove_esc(_option_after = aobj_get_description(obj, kp SUBSEP v) COMP_HELPDOC_UI_END generate_optarg_rule_string(obj, kp, v, "ARGS")) == "") continue
        _str = _str comp_helpdoc_unit_line( th_interval(COMP_HELPDOC_UI_THEME) _text_arr[i], _max_len, COMP_HELPDOC_HELP_INDENT_LEN, \
            th_interval(COMP_HELPDOC_UI_DESC) _option_after, COMP_HELPDOC_WIDTH - _max_len - COMP_HELPDOC_HELP_INDENT_LEN - COMP_HELPDOC_DESC_INDENT_LEN, COMP_HELPDOC_DESC_INDENT_LEN ) "\n"
    }
    if (_str == "") return
    return generate_title("ARGS:") "\n" _str "\n"
}

function generate_subcmd_help_unit( obj, kp, arr, arr_kp,        i, v, l, _str, _max_len, _option_after, _text_arr) {
    arr_clone_of_kp( arr, _text_arr, arr_kp )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( obj, kp, _text_arr )

    th_interval_init(COMP_HELPDOC_UI_THEME)
    th_interval_init(COMP_HELPDOC_UI_DESC)
    l = arr_len(arr, arr_kp)
    for (i=1; i<=l; ++i) {
        v = arr[ arr_kp SUBSEP "\""i"\"" ]
        if (obj[ kp, v ] == "") continue
        _option_after = aobj_get_description(obj, kp SUBSEP v) COMP_HELPDOC_UI_END
        _str = _str comp_helpdoc_unit_line( th_interval(COMP_HELPDOC_UI_THEME) _text_arr[i], _max_len, COMP_HELPDOC_HELP_INDENT_LEN, \
            th_interval(COMP_HELPDOC_UI_DESC) _option_after, COMP_HELPDOC_WIDTH - _max_len - COMP_HELPDOC_HELP_INDENT_LEN - COMP_HELPDOC_DESC_INDENT_LEN, COMP_HELPDOC_DESC_INDENT_LEN ) "\n"
    }
    return _str
}

function generate_subcmd_help( obj, kp, arr_group,          _str, _str_title, _str_footer, _str_unit, l, i, k) {
    if (! arr_group[ ADVISE_HAS_TAG ]) return
    _str_title = generate_title("SUBCOMMANDS:") "\n"
    if (arr_len(arr_group, ADVISE_NULL_TAG)) _str = _str generate_subcmd_help_unit( obj, kp, arr_group, ADVISE_NULL_TAG)
    l = arr_group[ L ]
    for (i=1; i<=l; ++i){
        k = arr_group[ i ]
        if (ADVISE_DEV_TAG[ SUBSEP k ]) continue
        if (! aobj_len( arr_group, k )) continue
        _str_unit = generate_subcmd_help_unit( obj, kp, arr_group, k)
        if ( _str_unit != "" ) _str = _str "    " COMP_HELPDOC_TAG_LEFT juq(k) COMP_HELPDOC_TAG_RIGHT "\n" _str_unit
    }
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
    th_interval_init(COMP_HELPDOC_UI_THEME)
    _str = generate_title("NAME:") "\n"
    n = obj[ kp ]
    if ( n == "{" ) {
        n = obj[ kp, 1 ]
        if ((d = obj[ kp, n ]) == "null") d = aobj_get_value_with_local_language(obj, kp, ___X_CMD_LANG)
    }
    _str = _str COMP_HELPDOC_HELP_INDENT_STR  th_interval(COMP_HELPDOC_UI_THEME) juq(n) COMP_HELPDOC_UI_END ( aobj_str_is_null(d) ? "" : " - " aobj_uq(d) ) "\n"
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
    return (_str != "") ? generate_title("DESCRIPTON:") "\n" _str : ""
}

function generate_synopsis_help(obj, kp,            l, i, k, v, _str) {
    kp = kp SUBSEP "\"#synopsis\""
    if (aobj_is_null( obj, kp)) return
    th_interval_init(COMP_HELPDOC_UI_THEME)
    _str = generate_title("SYNOPSIS:") "\n"
    v = obj[ kp ]
    if ( (v != "[") && (v != "") )
        return _str COMP_HELPDOC_HELP_INDENT_STR th( th_interval(COMP_HELPDOC_UI_THEME), aobj_uq(v) ) "\n\n"

    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, jqu(i), 1]
        v = obj[ kp, jqu(i), k]
        if (v == "null") v = aobj_get_value_with_local_language(obj, kp SUBSEP jqu(i), ___X_CMD_LANG)
        _str = _str COMP_HELPDOC_HELP_INDENT_STR str_cut_line( th_interval(COMP_HELPDOC_UI_THEME) juq(k) " " COMP_HELPDOC_UI_END aobj_uq(v), COMP_HELPDOC_HELP_INDENT_LEN) "\n"
    }
    return _str "\n"
}

function generate_tldr_help(obj, kp,            l, i, k, v, _str){
    kp = kp SUBSEP "\"#tldr\""
    if (aobj_is_null( obj, kp)) return
    th_interval_init(COMP_HELPDOC_UI_THEME)
    _str = generate_title("TLDR:") "\n"
    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, jqu(i), "\"cmd\"" ]
        v = aobj_get_value_with_local_language(obj, kp SUBSEP jqu(i), ___X_CMD_LANG)
        if ( ! aobj_str_is_null(v) ) _str = _str COMP_HELPDOC_HELP_INDENT_STR str_cut_line( th_interval(COMP_HELPDOC_UI_THEME) aobj_uq(v), COMP_HELPDOC_HELP_INDENT_LEN) "\n"
        _str = _str space_rep(COMP_HELPDOC_HELP_INDENT_LEN * 2) COMP_HELPDOC_UI_END  str_cut_line(aobj_uq(k), COMP_HELPDOC_HELP_INDENT_LEN * 2) "\n"
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
        _str = _str COMP_HELPDOC_UI_END COMP_HELPDOC_HELP_INDENT_STR juq(k) th_interval(COMP_HELPDOC_UI_THEME) " " aobj_uq(v) COMP_HELPDOC_UI_END "\n"
    }
    return _str
}

function generate_other_help(obj, kp,       l, i, k, v, _str){
    kp = kp SUBSEP "\"#other\""
    if (aobj_is_null( obj, kp)) return
    th_interval_init(COMP_HELPDOC_UI_THEME)
    return generate_title("SEE ALSO:") "\n" generate_other_help_unit(obj, kp)
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
    if (width < 45) return "The current width is not enough to display the help document!\n"
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
        else if ( s ~ "^#(([0-9]+)|n)$" ) arr_push( RESTOPT, v )
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
