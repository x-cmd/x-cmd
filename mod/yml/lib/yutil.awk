function yml_panic( s ){
    log_error("yml", s)
    YML_PANIC_EXIT = 1
    exit(1)
}
END{    if (YML_PANIC_EXIT != 0) exit( YML_PANIC_EXIT );    }

function yml_trim_ending_space_colon( s ){  return (match( s, "[ ]+:$")) ? substr(s, length(s) - RLENGTH): s;  }

function yml_match_tailing_comment( s ){      return match(s, "[ \t]#.+$");     }

function yml_match_comment( s ){      return match(s, "(^|[ \t])#.+$");     }

function yml_match_blankline_or_onlycomment( s ){       return match(s, "^[ \t]*(#.+)?$");     }
function yml_match_onlycomment( s ){                    return match(s, "^[ \t]*(#.+)$");     }


function yml_is_blankline( s ){      return (s ~ /^[ \t]*$/);     }
function yml_cal_indent( s ){ return match( s, /^[ ]+/ ) ? RLENGTH : 0; }

function yml_u_uq1( s ){    return juq1( s );   }
function yml_u_uq2( s ){    return juq( s );    }
function yml_u_uq3( s ){    return yml_u_trim_both( s );    }

# function yml_u_trim_left( s ){  return (match(s, /^[ \t\n]+/)) ? substr(s, RLENGTH+1) : s;  }
# function yml_u_trim_right( s ){ return (match(s, /[ \t\n]+$/)) ? substr(s, 1, length(s)-RLENGTH): s; }
function yml_u_trim_left( s ){  gsub(/^[ \t\n]+/, "", s); return s; }
function yml_u_trim_right( s ){ gsub(/[ \t\n]+$/, "", s); return s; }
function yml_u_trim_both( s ){  return yml_u_trim_right( yml_u_trim_left(s) );  }


BEGIN{
    RE_Y_VALUE_OCT = "0[oO][0-7]+"
    RE_Y_VALUE_OCT_0 = "0[0-7]+"
    RE_Y_VALUE_HEX = "0[xX][0-9A-Za-z]+"

    # RE_Y_VALUE_DEC = "[-+]?([0-9]+)(([.][0-9]+)([eE][+-]?[0-9]+))?" # RE_NUM is wrong
    # RE_FLOAT = "(-?[1-9][0-9]*.[0-9]+$|^-?0.[0-9]+$|^-?[1-9][0-9]*$|^0)"

    RE_Y_VALUE_DEC = "[-+]?[0-9]+"
    RE_Y_VALUE_FLOAT = "[-+]?(\\.[0-9]+|[0-9]+(\\.[0-9]*)?)([eE][-+]?[0-9]+)?"
}

function yml_oct2dec__slow( oct, idx,     r, i, l, a ){
    oct = substr(oct, (idx=="") ? 3 : idx)
    l = split(oct, a, "")
    for (i=1; i<=l; ++i) r = r * 8 + a[i]
    return r
}

function yml_oct2dec( oct, idx ){
    return yml_oct2dec__slow( oct, idx )
}

function yml_hex2dec( hex ) {
    return hex_to_dec(hex)
}

BEGIN{
    YML_RE_BOOL_TRUE = "(true|True|TRUE)"
    YML_RE_BOOL_FALSE = "(false|False|FALSE)"
    YML_RE_BOOL = re( YML_RE_BOOL_TRUE "|" YML_RE_BOOL_FALSE )

    YML_RE_NULL = "(null|Null|NULL|~)"
}

function yml_parse_special_value( o, k, r ){
    if (r == "") {
        yml_obj_unset_yval(o, k)
        return "null"
    }

    if (r ~ "^" RE_Y_VALUE_OCT "$") {
        yml_obj_set_yval( o, k, r )
        return yml_oct2dec(r, 3)
    }

    if (r ~ "^" RE_Y_VALUE_OCT_0 "$" ) {
        yml_obj_set_yval( o, k, r )
        return yml_oct2dec(r, 2)
    }

    if (r ~ "^" RE_Y_VALUE_HEX "$" ) {
        yml_obj_set_yval( o, k, r )
        return yml_hex2dec(r)
    }

    # TODO: How do you treat the +.inf -.inf and nan ?
    if (r ~ "^" RE_Y_VALUE_DEC "$") {
        yml_obj_set_yval( o, k, r )
        return sprintf("%d", r)
    }

    if (r ~ "^" RE_Y_VALUE_FLOAT "$") {
        yml_obj_set_yval( o, k, r )
        return r # sprintf("%f", r)
    }

    if (r ~ "^" YML_RE_BOOL "$") {
        yml_obj_set_yval( o, k, r )
        return tolower(r)
    }

    if (r ~  "^" YML_RE_NULL "$") {
        yml_obj_set_yval( o, k, r )
        return "null"
    }

    yml_obj_unset_yval(o, k)
    return (r ~ "^\"") ? r : jqu(r)
}

function yml_obj_set_yval( o, k, v ){
    o[ "ORIG" k ] = v
}

function yml_obj_unset_yval( o, k ){
    delete o[ "ORIG" k ]
}

function yml_obj_get_yval( o, k ){
    return o[ "ORIG" k ]
}

function yml_obj_get_yval_or_val( o, k,  a ){
    if (( a = o[ "ORIG" k ]) != "") return a
    return o[ k ]
}


function yml_parse_trim_value(o, k,     v){
    v = o[ k ]
    if (v == "[") return yml_parse_trim_list(o, k)
    if (v == "{") return yml_parse_trim_dict(o, k)
    o[ k ] = yml_parse_special_value(o, k, v)
}

function yml_parse_trim_list(o, k,     i, l){
    l = o[ k L ]
    for (i=1; i<=l; ++i) yml_parse_trim_value(o, k SUBSEP "\""i"\"")
}

function yml_parse_trim_dict(o, k,     i, l){
    l = o[ k L ]
    for (i=1; i<=l; ++i) yml_parse_trim_value(o, k SUBSEP o[k, i])
}

