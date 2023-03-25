
BEGIN{
    Y_BUF = "";     Y_BUF_VIND = 0
    Y_ARR_IDX = 0;  Y_ARR_NUM = 0
    Y_LAST_CMT = ""
}

# Section: cmt
function y_cmt_append( c1, c2 ) {
    if (c1 == "") return c2
    if (c2 == "") return c1
    return c1 "\n" c2
}

function y_cmt_set_for_root_0( o, k, cmt ){ if (cmt != "") o[ L L k ] = cmt; }
function y_cmt_set_for_root_1( o, k, cmt ){ if (cmt != "") o[ k L L ] = cmt; }
function y_cmt_set_for_key( o, k, cmt ){    if (cmt != "") o[ L k ] = cmt;   }
function y_cmt_set_for_val_0( o, k, cmt ){  if (cmt != "") o[ L L L k ] = cmt;  }
function y_cmt_set_for_val_1( o, k, cmt ){  if (cmt != "") o[ k L L L ] = cmt;  }
# EndSection

# Section: buf
function y_buf_next(){
    Y_BUF = Y_ARR_LINE[ ++ Y_ARR_IDX ]
    Y_BUF_VIND = 0
    match( Y_BUF, /^[ ]+/ )
    YML_ARR_LINE_INDENT = (RLENGTH == -1) ? 0 : RLENGTH
}

BEGIN{
    Y_RE_END_DOT_PAT = "^[.][.][.]([ ]|$)"
    Y_RE_END_HYPHEN_PAT = "^---([ ]|$)"
    Y_RE_END_PAT = "^(---)|(^[.][.][.])([ ]|$)"
}

function y_buf_eof(){
    if (Y_BUF ~ Y_RE_END_PAT) return true
    return Y_ARR_IDX > Y_ARR_NUM
}

function y_buf_squeeze( _ind ){
    if (_ind == "") _ind = yml_cal_indent( Y_BUF )
    Y_BUF = substr( Y_BUF, _ind + 1 )
    Y_BUF_VIND = Y_BUF_VIND + _ind
}

function yml_skip_blankline( ){
    for ( ; Y_ARR_IDX <= Y_ARR_NUM; y_buf_next() )
        if ( ! yml_is_blankline( Y_BUF ) ) return
}

function yml_skip_blankline_or_onlycomment( cmt ){
    cmt = ""
    for ( ; Y_ARR_IDX <= Y_ARR_NUM; y_buf_next() ) {
        if ( ! yml_match_blankline_or_onlycomment( Y_BUF ) ) return cmt
        if ( yml_match_comment( Y_BUF ) ) cmt = cmt yml_u_trim_left(substr(Y_BUF, RSTART)) "\n"
    }
    return cmt
}

# EndSection

function yml_setkv( o, k, v ){  o[ k ] = v; }
function yml_current_indent(){   return YML_ARR_LINE_INDENT;     }

# Section: parse list
function yml_parse_list( o, kp, least_indent,       c,  _kpn, _ind, _cmt ){
    if (Y_BUF !~ /(^-[ ])|(^-$)/) return false

    for (c=0; ;) {
        if (length(Y_BUF) == 1) y_buf_squeeze( 1 )
        else                    y_buf_squeeze( 2 )

        _kpn = kp SUBSEP "\"" (++c) "\""

        y_cmt_set_for_key( o, _kpn, _cmt )

        yml_setkv( o, _kpn, yml_parse_value( o, _kpn, least_indent + 1 ) )
        o[ kp L ] = c

        _cmt = y_cmt_append(Y_LAST_CMT, yml_skip_blankline_or_onlycomment())
        Y_LAST_CMT = ""
        if (y_buf_eof()) {
            Y_LAST_CMT = _cmt
            break
        }
        
        if ( (_ind = yml_current_indent( )) < least_indent )  break
        else if (_ind > least_indent)                               panic(sprintf("yml_parse_list() Expect indent equal to %s: %s", least_indent, Y_BUF))
        
        
        y_buf_squeeze()
        # if (Y_BUF !~ /(^-[ ])|(^-$)/)  panic(sprintf("Execpt - but get: %s", Y_BUF))
        if (Y_BUF !~ /(^-[ ])|(^-$)/)   break
    }
    return true
}
# EndSection

# Section: parse dict
function yml_parse_dict___consume_key(      k ){
    if (match(Y_BUF, "^" RE_STR1 "[ ]*:([ ]|$)")){
        k = substr( Y_BUF, 1, RLENGTH );  gsub(":[ ]?$", "", k);  y_buf_squeeze( RLENGTH )
        return jqu( yml_u_uq1( yml_trim_ending_space_colon( k ) ) )
    }

    if (match(Y_BUF, "^" RE_STR2 "[ ]*:([ ]|$)")) {
        k = substr( Y_BUF, 1, RLENGTH );  gsub(":[ ]?$", "", k);  y_buf_squeeze( RLENGTH )
        return jqu( yml_u_uq2( yml_trim_ending_space_colon( k ) ) )
    }

    if (match(Y_BUF, YML_RE_YML_KEYSTR)) {
        k = substr( Y_BUF, 1, RLENGTH );  gsub(":[ ]?$", "", k);  y_buf_squeeze( RLENGTH )
        return jqu( yml_u_uq3( yml_trim_ending_space_colon( k ) ) )
    }

    return ""
}

function yml_parse_dict( o, kp, least_indent,       _ind, k, c, _cmt ){
    for (c=0; ;) { 
        k = yml_parse_dict___consume_key( )
        
        if (k == "") {
            if (c == 0)     return false
            else            panic(sprintf("Expect ':': %s", Y_BUF))
        } 
        
        o[ kp , (++c) ] = k
        o[ kp L ] = c
        _kpn = kp SUBSEP k

        # COULD-SHUTDOWN
        # if (Y_BUF ~ "^([ ]+- )|([ ]*[^\"':][^:]*:[ |$])") panic("yml_parse_dict() Block sequence entries are not allowed in this context: " k ":" Y_BUF)

        y_cmt_set_for_key( o, _kpn, _cmt )

        yml_setkv( o, _kpn, yml_parse_value( o, _kpn, least_indent + 1, true ) )

        _cmt = y_cmt_append(Y_LAST_CMT, yml_skip_blankline_or_onlycomment())
        Y_LAST_CMT = ""
        if (y_buf_eof()) {
            Y_LAST_CMT = _cmt
            break
        }
        
        if ( (_ind = yml_current_indent( )) < least_indent)   break
        else if (_ind > least_indent)                               panic( sprintf("yml_parse_dict() Expect indent equal to %s: %s", least_indent, Y_BUF) )

        y_buf_squeeze()
    }
    
    return true
}
# EndSection

# Section: parse value
BEGIN{
    YML_RE_STR1_NO_LEFT = "(('')|[^'])*'"
    RE_STR2_NO_LEFT = RE_NOQUOTE2 re( RE_QUOTE_CONTROL_OR_UNICODE RE_NOQUOTE2, "*" ) "\""
}

function yml_parse_value___strx( least_indent,   _regex_brack_left, _regex_str,     r, _regex, _rl ){
    Y_LAST_CMT = ""
    if (match(Y_BUF, "^" _regex_brack_left _regex_str)){
        r = substr(Y_BUF, 1, RLENGTH)
        y_buf_squeeze( RLENGTH )
        return r
    }
    
    r = yml_u_trim_both(Y_BUF)
    y_buf_next()
    for (  ; Y_ARR_IDX <= Y_ARR_NUM; y_buf_next() ) {
        if ( yml_current_indent( ) < least_indent ) panic("Expect indent equal to " least_indent "in line[" Y_ARR_IDX "/" Y_ARR_NUM "] but get:|" Y_BUF )
        
        if (! match(Y_BUF, "^" _regex_str)){
            r = r " " yml_u_trim_both( Y_BUF )
            continue
        }
            
        r = r " " yml_u_trim_both(substr(Y_BUF, 1, _rl = RLENGTH))
        y_buf_squeeze( _rl )
        y_cmt_set_for_val_1( o, kp, yml_skip_blankline_or_onlycomment() )
        return r
    }
    
    panic("yml_parse_value___strx(): Cannot found match: " _regex_brack_left)
}

function yml_parse_value( o, kp, least_indent, _is_dict,      v, s, _cmt, _blank, _ind, _should_be_list, _anchor_name, _tag_name ){
    if (yml_match_blankline_or_onlycomment( Y_BUF )) {
        _blank = yml_is_blankline( Y_BUF )
        _cmt = yml_skip_blankline_or_onlycomment()
        if ( (_ind = yml_current_indent( )) < least_indent ) {
            if ( _blank )   Y_LAST_CMT = _cmt
            else            y_cmt_set_for_val_0( o, kp, _cmt )

            if (_is_dict && (_ind == least_indent - 1)) {
                _should_be_list = 1
            } else {
                y_cmt_set_for_val_1( o, kp, yml_parse_value___appending_oneblankline_or_multicomment( least_indent ) )
                return "null" # the list after key can be 
            }
        }
    }

    if ((Y_BUF_VIND == 0) && (Y_BUF ~ Y_RE_END_PAT)) {
        Y_LAST_CMT = y_cmt_append(Y_LAST_CMT, _cmt)
        return "null"
    }

    y_buf_squeeze( )

    if (match(Y_BUF, "^&[^& *]+")) {
        _anchor_name = substr(Y_BUF, 2, RLENGTH-1)
        o[ L L L L L _anchor_name ] = kp    # I don't know how to store it.
        y_buf_squeeze( RLENGTH )

        # y_cmt_set_for_val_0( o, kp, _cmt )  # comment for this anchor
        _cmt = y_cmt_append( _cmt, yml_skip_blankline_or_onlycomment() )

        y_buf_squeeze( )
    }

    if (match(Y_BUF, "(^!!?[A-Za-z0-9]+)|(^!<[^>]+>)")) {
        _tag_name = substr(Y_BUF, 1, RLENGTH)
        o[ "TAG_NAME" kp ] = kp
        y_buf_squeeze( RLENGTH )

        # TODO: comment for this tag or else
        _cmt = y_cmt_append( _cmt, yml_skip_blankline_or_onlycomment() )

        y_buf_squeeze( )
    }

    y_cmt_set_for_val_0( o, kp, _cmt )
    if ( yml_parse_list( o, kp, Y_BUF_VIND ) ) {    # Y_BUF_VIND could be least_indent-1
        # Notice: No comment follow
        return "["
    }

    if ( _should_be_list == 1 ) {
        # Notice: No comment follow
        return "null"
    }

    if ( yml_parse_dict( o, kp, Y_BUF_VIND ) ) {
        # Notice: No comment follow
        return "{"
    }

    if (match(Y_BUF, "^\\[")) {
        s = yml_parse_json__list( o, kp )
        yml_skip_blankline_or_onlycomment() # TODO: store comment
        return s
    }

    if (match(Y_BUF, "^\\{")) {
        s = yml_parse_json__dict( o, kp )
        yml_skip_blankline_or_onlycomment() # TODO: store comment
        return s
    }
    
    if (match(Y_BUF, "^\""))  {
        s = yml_parse_value___strx( least_indent, "\"", RE_STR2_NO_LEFT )
        y_cmt_set_for_val_1( o, kp, yml_parse_value___appending_oneblankline_or_multicomment( least_indent ) )
        return jqu( yml_u_uq2( s ) )
    }

    if (match(Y_BUF, "^'")) {
        s = yml_parse_value___strx( least_indent, "'",  YML_RE_STR1_NO_LEFT )
        y_cmt_set_for_val_1( o, kp, yml_parse_value___appending_oneblankline_or_multicomment( least_indent ) )
        return jqu( yml_unquote1( s ) )
    }

    if (Y_BUF ~ /^>[ \t]*/)                 return yml_parse_value___gt( o, kp, least_indent )           # >
    else if (Y_BUF ~ /^\|-[ \t]*/)          return yml_parse_value___vbar_minus( o, kp, least_indent )   # |-
    else if (Y_BUF ~ /^\|\+[ \t]*/)         return yml_parse_value___vbar_plus( o, kp, least_indent )    # |+
    else if (Y_BUF ~ /^\|[ \t]*/)           return yml_parse_value___vbar( o, kp, least_indent )         # |
    else if (match(Y_BUF, /^\*[^& *]+/))    return yml_parse_value___alias( o, kp, least_indent, substr(Y_BUF, 2, RLENGTH - 1) )
    else                                    return yml_parse_value___normalstring( o, kp, least_indent )
}
# EndSection

function yml_parse_root( o,   c, k, _cmt, _is_hyphen3, _is_blank ){

    while ( (_is_blank=yml_is_blankline( Y_BUF )) || (Y_BUF ~ "^%") ) {
        if ( !_is_blank ) {
        
            # TODO: store the directive
            # TODO: handle yml directive
            # TODO: handle tag directive
        }
        if (Y_ARR_IDX > NR) return     
        y_buf_next()
    }

    while ( ( _is_hyphen3 = match(Y_BUF, Y_RE_END_HYPHEN_PAT) ) || (yml_match_blankline_or_onlycomment( Y_BUF )) ) {
        if (_is_hyphen3)    y_buf_squeeze( RLENGTH )
        else {
            # add up cmt


            y_buf_next()
        }
    }
    
    c = 0; for ( ; Y_ARR_IDX <= Y_ARR_NUM; ) {    
        k = "" SUBSEP "\"" (++c) "\""
        # y_cmt_set_for_root_0( Y_LAST_CMT )    # We might consider getting the comment first
        o[ k ] = yml_parse_value( o, k, 0 )
        # debug( "Getting key: " k "\t" Y_ARR_IDX )
        y_cmt_set_for_root_1( o, k, Y_LAST_CMT )
        Y_LAST_CMT = ""
        o[ L ] = c

        # yml_skip_blankline_or_onlycomment()

        while ((Y_ARR_IDX <= Y_ARR_NUM) && (Y_BUF ~ Y_RE_END_DOT_PAT "|(^[ \t]*(#.+)*)$" ))  {
            y_buf_next()
        }
        if (Y_ARR_IDX <= Y_ARR_NUM) {
            if (Y_BUF !~ Y_RE_END_HYPHEN_PAT)           panic("Expecting --- but get: |" Y_BUF "|")
            y_buf_squeeze(RLENGTH)
            y_buf_next()
        }
        
    }
    return c 
}

function yml_parse( text, o   ){
    arr_cut(Y_ARR_LINE, text, "\n")

    o[ L ] = 0 

    Y_ARR_NUM = Y_ARR_LINE[ L ]

    Y_ARR_IDX = 0
    y_buf_next()

    yml_parse_root( o )
}
