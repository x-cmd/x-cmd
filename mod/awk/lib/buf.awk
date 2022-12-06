# Section: buf_module
function buf_init( text ){
    buf = ""
    buf_cur = 0
    buf[ L ] = split(text, buf, "\n")
}

function buf_next(){
    if (++buf_cur > buf[ L ]) return false
    buf = buf[ buf_cur ]
}

function buf_consume( l ){
    return buf = substr(buf, 1, (l == "") ? RLENGTH: l)
}

function buf_consume_line( e ){
    e = buf
    buf = ""
    return e
}

function buf_consume_tokenpat( tokenpat ){
    if (! buf_match( "^" tokenpat )) return false
    buf_consume()
    return true
}

function buf_next_if_empty( ){
    if (buf == "") return buf_next()
    return true
}

function buf_end(){
    return (buf_cur > buf[ L ])
}

function buf_match( pat ){
    return match( buf, pat )
}

function buf_startswith( astr ){
    if (substr(buf, 1, length(astr)) != astr) return false
    RLENGTH = length(astr)
    return true
}

function buf_consume_token( token ){
    if (! buf_startswith( token )) return false
    buf_consume()
    return true
}

function buf_substr( s, e ){
    return (e == "") ? substr( buf, s ) : substr( buf, s, e )
}

function buf_get(){     return buf;     }
function buf_set( b ){  return buf = b; }
## EndSection

# TODO: In the future, we introduce bufo
