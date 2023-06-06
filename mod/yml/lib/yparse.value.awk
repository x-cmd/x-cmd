
# Only for value
function yml_parse_value___appending_oneblankline_or_multicomment( least_indent,   cmt ){
    if ( yml_match_comment( Y_BUF )) {
        cmt = yml_u_trim_left(Y_BUF)
        y_buf_next()
    } else if( yml_is_blankline( Y_BUF )) {
        y_buf_next()
    }
    return yml_parse_value___appending_tailing_commentline( cmt, least_indent )
}

function yml_parse_value___appending_tailing_commentline( cmt, least_indent ) {
    for (  ; Y_ARR_IDX <= Y_ARR_NUM; y_buf_next() ) {
        if ( yml_current_indent( ) < least_indent ) break
        if ( ! yml_match_comment( Y_BUF) ) break
        cmt = cmt "\n" yml_u_trim_left(Y_BUF)
    }
    gsub("^\n+", "", cmt)
    return cmt
}


function yml_unquote1( e ){
    e = substr(e, 2, length(e) - 2)
    gsub("''", "'", e)
    return e
}

function yml_parse_value___normalstring( o, kp, least_indent,   r, e, _cmt, _rs ){

    if ( yml_match_tailing_comment( Y_BUF ) ) {
        r = yml_u_trim_both(substr(Y_BUF, 1, _rs = RSTART)) 
       
        _cmt = yml_u_trim_left(substr(Y_BUF, _rs+1))
        y_buf_next()
        _cmt = yml_parse_value___appending_tailing_commentline( _cmt, least_indent )
        if (_cmt != "")     y_cmt_set_for_val_1( o, kp, _cmt )
        return r
    }

    r = yml_u_trim_both( Y_BUF )
    y_buf_next()
    
    for (  ; Y_ARR_IDX <= Y_ARR_NUM; y_buf_next() ) {
        if ( yml_current_indent( ) < least_indent ) {
            if ( yml_u_trim_both(Y_BUF) != "") break
        }
        
        if ( ! yml_match_tailing_comment( Y_BUF ) ) {
            e = yml_u_trim_both( Y_BUF )
            if (e == "")    r = ((r=="") ? "" : r "\n")
            else            r = ((r=="") ? "" : (r " ")) e
        } else {
            e = yml_u_trim_both(substr(Y_BUF, 1, _rs = RSTART)) 
            if (e != "")    r = ((r=="") ? "" : (r " ")) e

            _cmt = yml_u_trim_left(substr(Y_BUF, _rs+1))
            y_buf_next()
            _cmt = yml_parse_value___appending_tailing_commentline( _cmt, least_indent )
            if (_cmt != "")     y_cmt_set_for_val_1( o, kp, _cmt )
            break
        }
    }

    gsub("^[ \n]+", "", r)
    gsub("[ \n]+$", "", r)
    
    return yml_parse_special_value( o, kp, r )
}


function yml_parse_value___add_line( o, kp, least_indent, arr,       l, r, _cmt, _ind ){
    if ( ! yml_match_tailing_comment( Y_BUF ) )     arr[++l] = Y_BUF
    else {
        arr[++l] = substr(Y_BUF, 1, RSTART)
        _cmt = yml_u_trim_left(substr(Y_BUF, RSTART+1))
    }

    y_buf_next()

    _ind = -1
    for (  ; Y_ARR_IDX <= Y_ARR_NUM; y_buf_next() ) {
        if ( yml_current_indent( ) < _ind ) {
            if ( yml_u_trim_both(Y_BUF) != "") break
        }
        if (_ind == -1) if ( (_ind = yml_current_indent( )) < least_indent ) break
        arr[++l] = Y_BUF
    }

    _cmt = yml_parse_value___appending_tailing_commentline( _cmt, least_indent )
    y_cmt_set_for_val_1( o, kp, _cmt )
    arr[ L ] = l
}

function yml_parse_value___gt( o, kp, least_indent,        a, i, l, e, _sep ){
    yml_parse_value___add_line( o, kp, least_indent, a )
    l = a[ L ]
    r = ""; _sep = " "; for (i=2 ; i<=l; ++i) {
        e = yml_u_trim_both( a[i] )
        if (e == "") {  r = r "\n";         _sep = "";  }
        else         {  r = r _sep e;       _sep = " "; }
    }
    return jqu(yml_u_trim_both(r))
}

function yml_parse_value___vbar( o, kp, least_indent,        a, i, l ){
    yml_parse_value___add_line( o, kp, least_indent, a )
    l = a[ L ]
    r = ""; for (i=2 ; i<=l; ++i)    r = ( (r=="") ? "" : (r "\n") ) yml_u_trim_both( a[i] )
    gsub(/[\n]+$/, "", r)
    if (Y_ARR_IDX <= Y_ARR_NUM)     r = r "\n"
    return jqu(r)
}


function yml_parse_value___vbar_minus( o, kp, least_indent,        a, i, l ){
    yml_parse_value___add_line( o, kp, least_indent, a )
    l = a[ L ]
    r = ""; for (i=2 ; i<=l; ++i)    r = ( (r=="") ? "" : (r "\n") ) yml_u_trim_both( a[i] )
    gsub(/[\n]+$/, "", r)
    return jqu(r)
}

function yml_parse_value___vbar_plus( o, kp, least_indent,        a, i, l ){
    yml_parse_value___add_line( o, kp, least_indent, a )
    l = a[ L ]
    r = ""; for (i=2 ; i<=l; ++i)    r = ( (r=="") ? "" : (r "\n") ) yml_u_trim_both( a[i] )
    return jqu(r)
}

# Section: anchor and value

function yml_parse_value___alias( o, kp, least_indent,          _anchor_name, _cmt, _ref_kp ){
    if ((_ref_kp = o[ L L L L L _anchor_name ]) == "") panic("Refering undefined alias[" _anchor_name "]: " Y_BUF)

    y_buf_squeeze( RLENGTH )
    _cmt = yml_parse_value___appending_oneblankline_or_multicomment( least_indent )
    y_cmt_set_for_val_1( o, kp, _cmt )
    return o[ _ref_kp ]
}

# EndSection
