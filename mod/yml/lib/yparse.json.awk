
function yml_parse_json_skip_space_until_token( cmt ){
    cmt = yml_skip_blankline_or_onlycomment( cmt )
    y_buf_squeeze()
    return cmt
}

BEGIN{

    YML_RE_JSON_KEYSTR = "^(" "(:+)" "|" "([^]{[}#:, ][^]{[}:,#]*)" ")+:" 
    YML_RE_YML_KEYSTR = "^(" "(:+)" "|" "([^]{[}\"':,# ][^:#]*)" ")+:([ ]|$)"
    YML_RE_JSON_STR = "^(" "(:+)" "|" "([^]{[}:,# ][^]{[}:,#]*)" ")+"
    
}

function yml_parse_json__dict_key(          r ){
    # Using str1, str2
    if (Y_BUF ~ "^'") {
        if (match(Y_BUF, "^'" YML_RE_STR1_NO_LEFT)) {
            r = substr(Y_BUF, RSTART, RLENGTH)
            y_buf_squeeze( RLENGTH )
            return jqu(yml_unquote1(r))
        } else {
            panic("Expecting a whole single quote stirng: " Y_BUF)
        }
    }

    if (Y_BUF ~ "^\"") {
        if (match(Y_BUF, "^\"" RE_STR2_NO_LEFT)) {
            r = substr(Y_BUF, RSTART, RLENGTH)
            y_buf_squeeze( RLENGTH )
            return jqu(yml_u_uq2(r))
        } else {
            panic("Expecting a whole double quote stirng: " Y_BUF)
        }
    }

    if (match(Y_BUF, YML_RE_JSON_KEYSTR)) {
        r = substr(Y_BUF, RSTART, RLENGTH-1)
        y_buf_squeeze( RLENGTH-1 )
        return jqu(yml_u_trim_both(r))
    }
    panic(" Expecting key but get: " Y_BUF)
}

function yml_parse_json__dict( o, kp,   c, k ){

    y_buf_squeeze(1) # "{"

    for (c=0; ; ) {
        yml_parse_json_skip_space_until_token() # TODO

        if (match(Y_BUF, "^}")) break

        o[ kp, (++ c) ] = _key = yml_parse_json__dict_key()
        
        yml_parse_json_skip_space_until_token()

        y_buf_squeeze(1) # ":"
        yml_parse_json_skip_space_until_token()

        o[ kp, _key ] = yml_parse_json__value( o, kp )

        yml_parse_json_skip_space_until_token() # TODO

        if (match(Y_BUF, "^,")) {
            y_buf_squeeze(1) # ","
        } else {
            if (match(Y_BUF, "^}")) break
        }
    }

    y_buf_squeeze(1) # "]"
    o[ kp L ] = c
    o[ kp ] = "{"
    return "{"
}

function yml_parse_json__list( o, kp,       c, k, v ){
    y_buf_squeeze(1) # "["

    for (c=0; ; ) {
        yml_parse_json_skip_space_until_token() # TODO

        if (match(Y_BUF, "^]")) break

        k = kp SUBSEP "\"" (++ c) "\""
        o[ k ] = yml_parse_json__value( o, kp )

        yml_parse_json_skip_space_until_token() # TODO

        if (match(Y_BUF, "^,")) {
            y_buf_squeeze(1) # ","
        } else {
            if (match(Y_BUF, "^\\]")) break
        }
    }

    y_buf_squeeze(1) # "]"
    o[ kp L ] = c
    o[ kp ] = "["
    return "["
}

# No white space ahead.
function yml_parse_json__value( o, kp ){
    if ( Y_BUF ~ "^\\[" )   return yml_parse_json__list( o, kp )
    if ( Y_BUF ~ "^\\{" )   return yml_parse_json__dict( o, kp )

    if ( Y_BUF ~ "^'" )     return yml_parse_json__value_mlqu1( )
    if ( Y_BUF ~ "^\"" )    return yml_parse_json__value_mlqu2( )

    return yml_parse_json__value_ml( o, kp )
}

function yml_parse_json__value_mlqu1( ){
    return jqu( yml_unquote1(   yml_parse_json_value___strx( "'", YML_RE_STR1_NO_LEFT ) ) )
}

function yml_parse_json__value_mlqu2( ){
    return jqu( yml_u_uq2(      yml_parse_json_value___strx( "\"", RE_STR2_NO_LEFT ) ) )
}

function yml_parse_json_value___strx(  _regex_brack_left, _regex_str,     r, _regex, _rl ){
    if (match(Y_BUF, "^" _regex_brack_left _regex_str "$")){
        r = substr(Y_BUF, 1, RLENGTH)
        y_buf_squeeze( RLENGTH )
        return r
    }
    
    r = yml_u_trim_both(Y_BUF)
    y_buf_next()
    for (  ; Y_ARR_IDX <= Y_ARR_NUM; y_buf_next() ) {
        if (match(Y_BUF, "^[ ]*$")) {
            r = r "\n"
            continue
        }

        if (! match(Y_BUF, "^" _regex_str)){
            r = r " " yml_u_trim_both( Y_BUF )
            continue
        }

        r = r " " yml_u_trim_both(substr(Y_BUF, 1, _rl = RLENGTH))
        y_buf_squeeze( _rl )
        return r
    }
    
    panic("yml_parse_value___strx(): Cannot found match: " _regex_brack_left)
}

function yml_parse_json__value_ml( o, kp, _nl, _res, _sep ){
    _sep = ""
    
    while ( (nl = (Y_BUF ~ "^[ ]*$")) || (match(Y_BUF, YML_RE_JSON_STR)) ){
        if (nl) {
            _res = _res _sep "\n"
            _sep = ""
            y_buf_next()
        } else {
            _res = _res _sep yml_u_trim_both( substr(Y_BUF, 1, RLENGTH) )
            _sep = " "
            y_buf_squeeze( RLENGTH )
        }
    }

    return yml_parse_special_value( o, kp,  _res )
}
